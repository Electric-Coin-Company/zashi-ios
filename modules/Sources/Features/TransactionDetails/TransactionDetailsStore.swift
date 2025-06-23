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

@Reducer
public struct TransactionDetails {
    @ObservableState
    public struct State: Equatable {
        public var CancelId = UUID()
        
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
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil
        public var transaction: TransactionState
        @Shared(.inMemory(.transactionMemos)) public var transactionMemos: [String: [String]] = [:]
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        public var annotationRequest = false
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var isAnnotationModified: Bool {
            annotation.trimmingCharacters(in: .whitespaces) != annotationOrigin
        }
        
        public var feeStr: String {
            transaction.fee?.decimalString() ?? L10n.TransactionHistory.defaultFee
        }
        
        public var memos: [String] {
            transactionMemos[transaction.id] ?? []
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
        case sentToRowTapped
        case transactionIdTapped
        case transactionsUpdated
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userMetadataProvider) var userMetadataProvider

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isSwap = userMetadataProvider.isSwapTransaction(state.transaction.id)
                state.hasInteractedWithBookmark = false
                state.areDetailsExpanded = false
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
                return .cancel(id: state.CancelId)
                
            case .observeTransactionChange:
                if state.transaction.isPending {
                    return .publisher {
                        state.$transactions.publisher
                            .map { _ in
                                TransactionDetails.Action.transactionsUpdated
                            }
                    }
                    .cancellable(id: state.CancelId, cancelInFlight: true)
                }
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
                userMetadataProvider.addAnnotationFor(state.annotation, state.transaction.id)
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
                
            case .sentToRowTapped:
                state.areDetailsExpanded.toggle()
                return .none
                
            case .addressTapped:
                pasteboard.setString(state.transaction.address.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none

            case .transactionIdTapped:
                pasteboard.setString(state.transaction.id.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none
            }
        }
    }
}
