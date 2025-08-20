//
//  TransactionDetailsStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-08-2024
//

import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils
import Models
import Generated
import Pasteboard
import SDKSynchronizer
import ReadTransactionsStorage
import ZcashSDKEnvironment
import AddressBookClient
import UIComponents
import AddressBookClient
import UserMetadataProvider
import SwapAndPay

@Reducer
public struct TransactionDetails {
    @ObservableState
    public struct State: Equatable {
        public var CancelId = UUID()
        public var SwapDetailsCancelId = UUID()

        enum Constants {
            static let messageExpandThreshold: Int = 130
            static let annotationMaxLength: Int = 90
        }
        
        public enum MessageState: Equatable {
            case longCollapsed
            case longExpanded
            case short
        }
        
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var annotationRequest = false
        public var areMessagesResolved = false
        public var alias: String?
        public var areDetailsExpanded = false
        public var hasInteractedWithBookmark = false
        public var isBookmarked = false
        public var isCloseButtonRequired = false
        public var isEditMode = false
        @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
        public var isSwap = false
        public var messageStates: [MessageState] = []
        public var annotation = ""
        public var annotationOrigin = ""
        public var annotationToInput = ""
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.swapAssets)) public var swapAssets: IdentifiedArrayOf<SwapAsset> = []
        public var swapAssetFailedWithRetry: Bool? = nil
        public var swapDetails: SwapDetails?
        public var umSwapId: UMSwapId?
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil
        public var transaction: TransactionState
        @Shared(.inMemory(.transactionMemos)) public var transactionMemos: [String: [String]] = [:]
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var isAnnotationModified: Bool {
            annotationToInput.trimmingCharacters(in: .whitespaces) != annotationOrigin
        }
        
        public var feeStr: String {
            transaction.fee?.decimalString() ?? L10n.TransactionHistory.defaultFee
        }
        
        public var memos: [String] {
            transactionMemos[transaction.id] ?? []
        }

        public var totalFeesStr: String? {
            guard let totalFees = umSwapId?.totalFees else {
                return nil
            }
            
            return Zatoshi(totalFees).decimalString()
        }
        
        public init(
            transaction: TransactionState
        ) {
            self.transaction = transaction
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case addNoteTapped
        case addressTapped
        case binding(BindingAction<TransactionDetails.State>)
        case bookmarkTapped
        case checkSwapAssets
        case checkSwapStatus
        case closeDetailTapped
        case deleteNoteTapped
        case memosLoaded([Memo])
        case messageTapped(Int)
        case noteButtonTapped
        case onAppear
        case onDisappear
        case observeTransactionChange
        case resolveMemos
        case saveAddressTapped
        case saveNoteTapped
        case sendAgainTapped
        case showHideButtonTapped
        case swapAssetsFailedWithRetry(Bool)
        case swapAssetsLoaded(IdentifiedArrayOf<SwapAsset>)
        case swapDetailsLoaded(SwapDetails?)
        case swapRecipientTapped
        case transactionIdTapped
        case transactionsUpdated
        case trySwapsAssetsAgainTapped
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.swapAndPay) var swapAndPay
    @Dependency(\.userMetadataProvider) var userMetadataProvider

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isSwap = userMetadataProvider.isSwapTransaction(state.transaction.id)
                state.umSwapId = userMetadataProvider.swapDetailsForTransaction(state.transaction.id)
                state.hasInteractedWithBookmark = false
                state.areDetailsExpanded = state.transaction.isShieldingTransaction
                state.messageStates = []
                state.alias = nil
                for contact in state.addressBookContacts.contacts {
                    if contact.id == state.transaction.address {
                        state.alias = contact.name
                        break
                    }
                }
                state.areMessagesResolved = false
                state.isBookmarked = userMetadataProvider.isBookmarked(state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationOrigin = state.annotation
                state.areMessagesResolved = !state.memos.isEmpty
                if state.memos.isEmpty {
                    return .merge(
                        .send(.resolveMemos),
                        .send(.observeTransactionChange)
                    )
                }
                return .send(.observeTransactionChange)

            case .onDisappear:
                if state.hasInteractedWithBookmark {
                    if let account = state.selectedWalletAccount?.account {
                        try? userMetadataProvider.store(account)
                    }
                }
                return .merge(
                    .cancel(id: state.CancelId),
                    .cancel(id: state.SwapDetailsCancelId)
                )
                
            case .swapAssetsFailedWithRetry(let retry):
                state.swapAssetFailedWithRetry = retry
                return .none
                
            case .trySwapsAssetsAgainTapped:
                return .send(.checkSwapAssets)

            case .observeTransactionChange:
                if state.transaction.isPending {
                    return .merge(
                        .publisher {
                            state.$transactions.publisher
                                .map { _ in
                                    TransactionDetails.Action.transactionsUpdated
                                }
                        }
                        .cancellable(id: state.CancelId, cancelInFlight: true),
                        .send(.checkSwapAssets)
                    )
                }
                return .send(.checkSwapAssets)
                
            case .checkSwapAssets:
                guard state.swapAssets.isEmpty else {
                    return .send(.checkSwapStatus)
                }
                return .run { send in
                    do {
                        let swapAssets = try await swapAndPay.swapAssets()
                        await send(.swapAssetsLoaded(swapAssets))
                    } catch let error as NetworkError {
                        await send(.swapAssetsFailedWithRetry(error.allowsRetry))
                    } catch { }
                }
                
            case .swapAssetsLoaded(let swapAssets):
                state.swapAssetFailedWithRetry = nil
                // exclude all tokens with price == 0
                // exclude zec token
                let filteredSwapAssets = swapAssets.filter { !($0.token.lowercased() == "zec" || $0.usdPrice == 0) }
                state.$swapAssets.withLock { $0 = filteredSwapAssets }
                return .send(.checkSwapStatus)
                
            case .checkSwapStatus:
                //return .none
                guard state.isSwap else {
                    return .none
                }
                return .run { [address = state.transaction.address] send in
                    let swapDetails = try? await swapAndPay.status(address)
                    await send(.swapDetailsLoaded(swapDetails))
                    
                    // fire another check if not done
                    if swapDetails?.status != .success {
                        try? await mainQueue.sleep(for: .seconds(10))
                        await send(.checkSwapStatus)
                    }
                }
                .cancellable(id: state.SwapDetailsCancelId, cancelInFlight: true)
                
            case .swapDetailsLoaded(let swapDetails):
                state.swapDetails = swapDetails
                return .none
                
            case .transactionsUpdated:
                if let index = state.transactions.index(id: state.transaction.id) {
                    let transaction = state.transactions[index]
                    if state.transaction != transaction {
                        state.transaction = transaction
                    }
                    if !transaction.isPending {
                        return .cancel(id: state.CancelId)
                    }
                }
                return .none
                
            case .binding(\.annotation):
                if state.annotation.count > TransactionDetails.State.Constants.annotationMaxLength {
                    state.annotation = String(state.annotation.prefix(TransactionDetails.State.Constants.annotationMaxLength))
                }
                return .none
                
            case .binding:
                return .none

            case .closeDetailTapped:
                return .none
                
            case .deleteNoteTapped:
                userMetadataProvider.deleteAnnotationFor(state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationRequest = false
                if let account = state.selectedWalletAccount?.account {
                    try? userMetadataProvider.store(account)
                }
                return .none

            case .saveNoteTapped, .addNoteTapped:
                userMetadataProvider.addAnnotationFor(state.annotationToInput, state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationOrigin = ""
                state.annotationRequest = false
                if let account = state.selectedWalletAccount?.account {
                    try? userMetadataProvider.store(account)
                }
                return .none

            case .resolveMemos:
                if let rawID = state.transaction.rawID {
                    return .run { send in
                        if let memos = try? await sdkSynchronizer.getMemos(rawID) {
                            await send(.memosLoaded(memos))
                        }
                    }
                }
                state.areMessagesResolved = true
                return .none

            case .memosLoaded(let memos):
                state.areMessagesResolved = true
                state.$transactionMemos.withLock {
                    $0[state.transaction.id] = memos.compactMap { $0.toString() }
                }
                state.messageStates = state.memos.map {
                    $0.count < State.Constants.messageExpandThreshold ? .short : .longCollapsed
                }
                return .none

            case .noteButtonTapped:
                state.isEditMode = !state.annotation.isEmpty
                state.annotationOrigin = state.annotation
                state.annotationToInput = state.annotation
                state.annotationRequest = true
                return .none

            case .bookmarkTapped:
                state.hasInteractedWithBookmark = true
                userMetadataProvider.toggleBookmarkFor(state.transaction.id)
                state.isBookmarked = userMetadataProvider.isBookmarked(state.transaction.id)
                return .none

            case .messageTapped(let index):
                if index < state.messageStates.count && state.messageStates[index] != .short {
                    if state.messageStates[index] == .longExpanded {
                        state.messageStates[index] = .longCollapsed
                    } else {
                        state.messageStates[index] = .longExpanded
                    }
                }
                return .none

            case .saveAddressTapped:
                return .none
                
            case .sendAgainTapped:
                return .none
                
//            case .sentToRowTapped:
//                state.areDetailsExpanded.toggle()
//                return .none
                
            case .addressTapped:
                pasteboard.setString(state.transaction.address.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none

            case .transactionIdTapped:
                pasteboard.setString(state.transaction.id.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none
                
            case .swapRecipientTapped:
                if let recipient = state.swapRecipient {
                    pasteboard.setString(recipient.redacted)
                    state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                }
                return .none
                
            case .showHideButtonTapped:
                state.areDetailsExpanded.toggle()
                return .none
            }
        }
    }
}

extension TransactionDetails.State {
    public var slippageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter
    }
    
    public var conversionFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale.current
        
        return formatter
    }
    
    public var swapStatus: SwapBadge.Status? {
        guard let status = swapDetails?.status else {
            return nil
        }
        
        switch status {
        case .pending: return .pending
        case .refunded: return .refunded
        case .success: return .success
        }
    }
    
    public var swapSlippage: String? {
        guard let slippage = swapDetails?.slippage else {
            return nil
        }
        
        let value = slippageFormatter.string(from: NSDecimalNumber(decimal: slippage)) ?? ""
        
        return "\(value)%"
    }
    
    public var swapAmountIn: String? {
        guard let amountInFormatted = swapDetails?.amountInFormatted else {
            return nil
        }
        
        return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInFormatted))
    }
    
    public var swapAmountInUsd: String? {
        swapDetails?.amountInUsd?.localeUsd
    }
    
    public var swapAmountOut: String? {
        guard let amountOutFormatted = swapDetails?.amountOutFormatted else {
            return nil
        }
        
        return conversionFormatter.string(from: NSDecimalNumber(decimal: amountOutFormatted))
    }
    
    public var swapAmountOutUsd: String? {
        swapDetails?.amountOutUsd?.localeUsd
    }
    
    public var swapIsSwap: Bool {
        swapDetails?.isSwap ?? false
    }
    
    public var swapDestinationAsset: SwapAsset? {
        guard !swapAssets.isEmpty else {
            return nil
        }
        
        guard swapAmountOut != nil else {
            return nil
        }
        
        guard let swapDetailsDestinationAssetId = swapDetails?.destinationAsset?.lowercased() else {
            return nil
        }
        
        return swapAssets.first { $0.assetId.lowercased() == swapDetailsDestinationAssetId }
    }
    
    public var refundedAmount: String? {
        guard let refundedAmountFormatted = swapDetails?.refundedAmountFormatted else {
            return nil
        }
        
        return conversionFormatter.string(from: NSDecimalNumber(decimal: refundedAmountFormatted)) ?? ""
    }
    
    public var swapRecipient: String? {
        swapDetails?.swapRecipient
    }
}
