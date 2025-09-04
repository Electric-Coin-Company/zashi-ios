//
//  SwapAndPayStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 23.05.2025.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import ZcashSDKEnvironment
import Utils

import Models
import BalanceBreakdown
import SDKSynchronizer
import WalletBalances
import SwapAndPay
import AddressBookClient
import WalletStorage
import UserMetadataProvider
import UserPreferencesStorage
import BigDecimal

@Reducer
public struct SwapAndPay {
    @ObservableState
    public struct State {
        public var SwapAssetsCancelId = UUID()
        public var ABCancelId = UUID()

        public var address = ""
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var amountAssetText = ""
        public var amountUsdText = ""
        public var amountText = ""
        public var assetSelectBinding = false
        public var balancesBinding = false
        public var balancesState = Balances.State.initial
        public var chain: String?
        @Shared(.inMemory(.exchangeRate)) public var currencyConversion: CurrencyConversion? = nil
        public var customSlippage = ""
        public var isAddressBookHintVisible = false
        public var isCancelSheetVisible = false
        public var isCurrencyConversionEnabled = false
        public var isInputInUsd = false
        public var isNotAddressInAddressBook = false
        public var isPopToRootBack = false
        public var isQuoteRequestInFlight = false
        public var isQuotePresented = false
        public var isQuoteUnavailablePresented = false
        public var isSlippagePresented = false
        public var isSwapCanceled = false
        public var isSwapExperienceEnabled = true
        public var optionOneChecked = false
        public var optionTwoChecked = false
        public var selectedContact: Contact?
        public var selectedOperationChip = 0
        public var proposal: Proposal?
        public var quote: SwapQuote?
        public var quoteRequestedTime: TimeInterval = 0
        public var quoteUnavailableErrorMsg = ""
        public var searchTerm = ""
        public var selectedAsset: SwapAsset?
        public var sheetHeight: CGFloat = 0.0
        public var slippage: Decimal = 1.0
        public var slippageInSheet: Decimal = 1.0
        public var selectedSlippageChip = 0
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.swapAPIAccess)) var swapAPIAccess: WalletStorage.SwapAPIAccess = .direct
        @Shared(.inMemory(.swapAssets)) public var swapAssets: IdentifiedArrayOf<SwapAsset> = []
        public var swapAssetFailedWithRetry: Bool? = nil
        public var swapAssetsToPresent: IdentifiedArrayOf<SwapAsset> = []
        public var token: String?
        public var walletBalancesState: WalletBalances.State
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil
        public var zecAsset: SwapAsset?

        public var isValidForm: Bool {
            selectedAsset != nil
            && !address.isEmpty
            && amount > 0
            && !isInsufficientFunds
        }
        
        public var isInsufficientFunds: Bool {
            guard let selectedAsset else {
                return false
            }
            
            guard let zecAsset else {
                return false
            }

            let spendableZec = walletBalancesState.shieldedBalance.decimalValue.decimalValue
            
            switch (isSwapExperienceEnabled, isInputInUsd) {
            case (true, false):
                return amount > spendableZec
            case (true, true):
                return (amount / zecAsset.usdPrice) > spendableZec
            case (false, false):
                return ((amount * selectedAsset.usdPrice) / zecAsset.usdPrice) > spendableZec
            case (false, true):
                return (amount / zecAsset.usdPrice) > spendableZec
            }
        }

        public var isCustomSlippageFieldVisible: Bool {
            slippageInSheet >= 40.0
        }

        public var spendability: Spendability {
            walletBalancesState.spendability
        }
        
        public var amount: Decimal {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter

                return numberFormatter.number(amountText)?.decimalValue ?? 0.0
            } else {
                return 0.0
            }
        }
        
        public var assetAmount: Decimal {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter

                return numberFormatter.number(amountAssetText)?.decimalValue ?? 0.0
            } else {
                return 0.0
            }
        }

        public var usdAmount: Decimal {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter

                return numberFormatter.number(amountUsdText)?.decimalValue ?? 0.0
            } else {
                return 0.0
            }
        }
    }

    public enum Action: BindableAction {
        case assetSelectRequested
        case assetTapped(SwapAsset)
        case backButtonTapped(Bool)
        case balances(Balances.Action)
        case binding(BindingAction<SwapAndPay.State>)
        case cancelPaymentTapped
        case cancelSwapTapped
        case closeAssetsSheetTapped
        case closeSlippageSheetTapped
        case confirmButtonTapped
        case confirmWithKeystoneTapped
        case customBackRequired
        case dismissRequired
        case dontCancelTapped
        case editPaymentTapped
        case enableSwapExperience
        case eraseSearchTermTapped
        case exchangeRateSetupChanged
        case getQuoteTapped
        case helpSheetRequested(Int)
        case internalBackButtonTapped
        case nextTapped
        case onAppear
        case onDisappear
        case proposal(Proposal)
        case quoteUnavailable(String)
        case refreshSwapAssets
        case scanTapped
        case sendFailed(ZcashError)
        case slippageChipTapped(Int)
        case slippageSetConfirmTapped
        case slippageTapped
        case swapAssetsFailedWithRetry(Bool)
        case swapAssetsLoaded(IdentifiedArrayOf<SwapAsset>)
        case swapQuoteLoaded(SwapQuote)
        case switchInputTapped
        case trySwapsAssetsAgainTapped
        case updateAssetsAccordingToSearchTerm
        case walletBalances(WalletBalances.Action)
        case willEnterForeground
        
        // Opt-in
        case confirmForcedOptInTapped
        case confirmOptInTapped
        case goBackForcedOptInTapped
        case optionOneTapped
        case optionTwoTapped
        case skipOptInTapped
        
        // Address Book
        case addressBookContactSelected(String)
        case addressBookTapped
        case addressBookUpdated
        case checkSelectedContact
        case dismissAddressBookHint
        case notInAddressBookButtonTapped(String)
        case selectedContactClearTapped
        case selectedContactUpdated
        
        // crosspay
        case backFromConfirmationTapped
        case crossPayConfirmationRequired
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.swapAndPay) var swapAndPay
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.balancesState, action: \.balances) {
            Balances()
        }

        Scope(state: \.walletBalancesState, action: \.walletBalances) {
            WalletBalances()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.walletBalances(.onAppear)),
                    .send(.refreshSwapAssets),
                    .send(.exchangeRateSetupChanged)
                )

            case .binding(\.customSlippage):
                if !state.customSlippage.isEmpty {
                    if let input = state.slippageFormatter.number(from: state.customSlippage)?.decimalValue, input > 0.0 && input < 100.0 {
                        state.slippageInSheet = input
                    }
                } else {
                    state.slippageInSheet = 0.0
                }
                return .none
                
            case .binding(\.searchTerm):
                return .send(.updateAssetsAccordingToSearchTerm)
                
            case .binding(\.address):
                return .send(.checkSelectedContact)

            case .onDisappear:
                return .merge(
                    .cancel(id: state.SwapAssetsCancelId),
                    .cancel(id: state.ABCancelId)
                )
                
            case .willEnterForeground:
                let diff = Date().timeIntervalSince1970 - state.quoteRequestedTime
                if diff > 180 {
                    state.isQuotePresented = false
                }
                return .none
                
            case .walletBalances(.availableBalanceTapped):
                state.balancesBinding = true
                return .none

            case .exchangeRateSetupChanged:
                if let automatic = userStoredPreferences.exchangeRate()?.automatic, automatic {
                    state.isCurrencyConversionEnabled = true
                } else {
                    state.isCurrencyConversionEnabled = false
                }
                return .none
                
            case .balances(.dismissTapped):
                state.balancesBinding = false
                return .none
                
            case .balances(.shieldFundsTapped):
                state.balancesBinding = false
                return .none
                
            case .balances(.everythingSpendable):
                if state.balancesBinding {
                    state.balancesBinding = false
                }
                return .none
                
            case .balances(.sheetHeightUpdated(let value)):
                state.sheetHeight = value
                return .none

            case .trySwapsAssetsAgainTapped:
                return .send(.refreshSwapAssets)

            case .backButtonTapped(let isSwapInFlight):
                if !isSwapInFlight {
                    return .send(.customBackRequired)
                }
                state.isCancelSheetVisible = true
                return .none
                
            case .internalBackButtonTapped:
                return .none
                
            case .helpSheetRequested:
                return .none
                
            case .customBackRequired:
                return .none

            case .cancelSwapTapped:
                state.isCancelSheetVisible = false
                state.isSwapCanceled = true
                return .concatenate(
                    .send(.onDisappear),
                    .send(.customBackRequired)
                )
                
            case .dontCancelTapped:
                state.isCancelSheetVisible = false
                if state.proposal != nil {
                    state.isQuotePresented = true
                }
                return .none

            case .refreshSwapAssets:
                return .run { send in
                    do {
                        let swapAssets = try await swapAndPay.swapAssets()
                        await send(.swapAssetsLoaded(swapAssets))
                    } catch let error as NetworkError {
                        await send(.swapAssetsFailedWithRetry(error.allowsRetry))
                    } catch { }
                    try? await mainQueue.sleep(for: .seconds(30))
                    await send(.refreshSwapAssets)
                }
                .cancellable(id: state.SwapAssetsCancelId, cancelInFlight: true)
                
            case .swapAssetsFailedWithRetry(let retry):
                state.swapAssetFailedWithRetry = retry
                return .none

            case .enableSwapExperience:
                state.isSwapExperienceEnabled.toggle()
                if !state.isInputInUsd {
                    if state.isSwapExperienceEnabled {
                        if let zecAsset = state.zecAsset, let selectedAsset = state.selectedAsset, !state.amountText.isEmpty {
                            let amountInToken = (state.amount * selectedAsset.usdPrice) / zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let zecAsset = state.zecAsset, let selectedAsset = state.selectedAsset, !state.amountText.isEmpty {
                            let amountInToken = (state.amount * zecAsset.usdPrice) / selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) {
                                state.amountText = value
                            }
                        }
                    }
                }
                return .none
            
            case .cancelPaymentTapped:
                state.isQuoteUnavailablePresented = false
                return .none

            case .editPaymentTapped:
                state.isQuoteUnavailablePresented = false
                return .none

            case .scanTapped:
                return .none

            case .updateAssetsAccordingToSearchTerm:
                // all received assets
                var swapAssets = state.swapAssets
                if let chainId = state.selectedContact?.chainId {
                    let filteredSwapAssets = swapAssets.filter { $0.chain.lowercased() == chainId.lowercased() }
                    swapAssets = filteredSwapAssets
                }
                guard !state.searchTerm.isEmpty else {
                    state.swapAssetsToPresent = swapAssets
                    return .none
                }
                state.swapAssetsToPresent.removeAll()
                let tokenNameMatch = swapAssets.filter { $0.tokenName.localizedCaseInsensitiveContains(state.searchTerm) }
                let tokenMatch = swapAssets.filter { $0.token.localizedCaseInsensitiveContains(state.searchTerm) }
                let chainNameMatch = swapAssets.filter { $0.chainName.localizedCaseInsensitiveContains(state.searchTerm) }
                let chainMatch = swapAssets.filter { $0.chain.localizedCaseInsensitiveContains(state.searchTerm) }
                state.swapAssetsToPresent.append(contentsOf: tokenNameMatch)
                state.swapAssetsToPresent.append(contentsOf: tokenMatch)
                state.swapAssetsToPresent.append(contentsOf: chainNameMatch)
                state.swapAssetsToPresent.append(contentsOf: chainMatch)
                return .none

            case .assetTapped(let asset):
                state.selectedAsset = asset
                state.assetSelectBinding = false
                return .none

            case .switchInputTapped:
                state.isInputInUsd.toggle()
                if state.isSwapExperienceEnabled {
                    if state.isInputInUsd {
                        if let zecAsset = state.zecAsset, !state.amountText.isEmpty {
                            let amountInUsd = state.amount * zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd.simplified)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let zecAsset = state.zecAsset, !state.amountText.isEmpty {
                            let amountInUsd = state.amount / zecAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd.simplified)) {
                                state.amountText = value
                            }
                        }
                    }
                } else {
                    if state.isInputInUsd {
                        if let selectedAsset = state.selectedAsset, !state.amountText.isEmpty {
                            let amountInUsd = state.amount * selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd.simplified)) {
                                state.amountText = value
                            }
                        }
                    } else {
                        if let selectedAsset = state.selectedAsset, !state.amountText.isEmpty {
                            let amountInUsd = state.amount / selectedAsset.usdPrice
                            if let value = state.conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd.simplified)) {
                                state.amountText = value
                            }
                        }
                    }
                }
                return .none
                
            case .assetSelectRequested:
                state.searchTerm = ""
                state.assetSelectBinding = true
                return .send(.updateAssetsAccordingToSearchTerm)
                
            case .slippageChipTapped(let index):
                state.selectedSlippageChip = index
                switch index {
                case 0:
                    state.slippageInSheet = 0.5
                    state.customSlippage = ""
                case 1:
                    state.slippageInSheet = 1.0
                    state.customSlippage = ""
                case 2:
                    state.slippageInSheet = 2.0
                    state.customSlippage = ""
                case 3: if state.customSlippage.isEmpty {
                    state.slippageInSheet = 0.0
                }
                default: break
                }
                return .none
                
            case .balances:
                return .none
                
            case .closeAssetsSheetTapped:
                state.assetSelectBinding = false
                return .none

            case .closeSlippageSheetTapped:
                state.isSlippagePresented = false
                return .none
                
            case .nextTapped:
                return .none
                
            case .eraseSearchTermTapped:
                state.searchTerm = ""
                return .send(.updateAssetsAccordingToSearchTerm)
                
            case .getQuoteTapped:
                guard let zecAsset = state.zecAsset else {
                    return .none
                }
                
                guard let toAsset = state.selectedAsset else {
                    return .none
                }
                
                guard let refundTo = state.zashiWalletAccount?.transparentAddress else {
                    return .none
                }
                
                guard let zecAmountDecimal = numberFormatter.number(state.zecToBeSpend)?.decimalValue else {
                    return .none
                }

                guard let tokenAmountDecimal = numberFormatter.number(state.amountText)?.decimalValue else {
                    return .none
                }

                let exactInput = state.isSwapExperienceEnabled
                let slippageTolerance = NSDecimalNumber(decimal: (state.slippage * 100.0)).intValue
                let destination = state.address
                let zecAmountInt = NSDecimalNumber(decimal: zecAmountDecimal)
                    .multiplying(by: NSDecimalNumber(value: Zatoshi.Constants.oneZecInZatoshi)).int64Value
                var amountString = String(zecAmountInt)
                if !state.isSwapExperienceEnabled {
                    let bigTokenAmountDecimal = BigDecimal(tokenAmountDecimal)
                    let pow10 = BigDecimal(pow(10.0, Double(toAsset.decimals)))
                    let bigTokenAmount = bigTokenAmountDecimal * pow10
                    amountString = bigTokenAmount.asString(.plain)
                    if let first = amountString.split(separator: ".").first {
                        amountString = String(first)
                    }
                }
                state.isQuoteRequestInFlight = true
                state.quoteRequestedTime = Date().timeIntervalSince1970
                return .run { [amountString] send in
                    do {
                        let swapQuote = try await swapAndPay.quote(
                            false,
                            exactInput,
                            slippageTolerance,
                            zecAsset,
                            toAsset,
                            refundTo,
                            destination,
                            amountString
                        )
                        await send(.swapQuoteLoaded(swapQuote))
                    } catch SwapAndPayClient.EndpointError.message(let errorMsg) {
                        await send(.quoteUnavailable(errorMsg))
                    } catch let error as NetworkError {
                        await send(.quoteUnavailable("Error: \(error.message)"))
                    } catch {
                        await send(.quoteUnavailable("Error: \(error.localizedDescription)"))
                    }
                }

            case .swapQuoteLoaded(let quote):
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                state.quote = quote
                let zecAmount = Zatoshi(NSDecimalNumber(decimal: quote.amountIn).int64Value)
                return .run { send in
                    do {
                        let recipient = try Recipient(quote.depositAddress, network: zcashSDKEnvironment.network.networkType)

                        let proposal = try await sdkSynchronizer.proposeTransfer(account.id, recipient, zecAmount, nil)
                        
                        await send(.proposal(proposal))
                    } catch {
                        await send(.sendFailed(error.toZcashError()))
                    }
                }

            case .proposal(let proposal):
                if state.isSwapCanceled {
                    return .none
                }
                state.proposal = proposal
                if !state.isCancelSheetVisible {
                    state.isQuotePresented = true
                    if !state.isSwapExperienceEnabled {
                        return .send(.crossPayConfirmationRequired)
                    }
                }
                state.isQuoteRequestInFlight = false
                return .none
                
            case .confirmButtonTapped:
                state.isQuotePresented = false
                return .none
                
            case .sendFailed(let error):
                state.quoteUnavailableErrorMsg = error.localizedDescription
                state.isQuoteUnavailablePresented = true
                return .none
                
            case .quoteUnavailable(let errorMsg):
                state.isQuoteRequestInFlight = false
                state.isQuoteUnavailablePresented = true
                state.quoteUnavailableErrorMsg = errorMsg
                return .none
                
            case .slippageTapped:
                state.isSlippagePresented = true
                state.slippageInSheet = state.slippage
                state.customSlippage = ""
                switch state.slippage {
                case 0.5: state.selectedSlippageChip = 0
                case 1.0: state.selectedSlippageChip = 1
                case 2.0: state.selectedSlippageChip = 2
                default:
                    state.selectedSlippageChip = 3
                    if let value = state.slippageFormatter.string(from: NSDecimalNumber(decimal: state.slippage)) {
                        state.customSlippage = value
                    }
                }
                return .none
                
            case .slippageSetConfirmTapped:
                state.isSlippagePresented = false
                state.slippage = state.slippageInSheet
                return .none
                
            case .dismissRequired:
                return .none
                
            case .swapAssetsLoaded(let swapAssets):
                state.swapAssetFailedWithRetry = nil
                state.zecAsset = swapAssets.first(where: { $0.token.lowercased() == "zec" })
                if state.selectedAsset == nil && state.selectedContact == nil {
                    if let lastUsedAssetId = userMetadataProvider.lastUsedAssetHistory().first {
                        state.selectedAsset = swapAssets.first { $0.id == lastUsedAssetId }
                    }

                    if state.selectedAsset == nil {
                        state.selectedAsset = swapAssets.first { $0.token.lowercased() == "usdc" && $0.chain.lowercased() == "near" }
                    }
                }

                // exclude all tokens with price == 0
                // exclude zec token
                var filteredSwapAssets = swapAssets.filter { !($0.token.lowercased() == "zec" || $0.usdPrice == 0) }
                
                // history assets
                let historyAssetIds = userMetadataProvider.lastUsedAssetHistory()
                var historyAssets: IdentifiedArrayOf<SwapAsset> = []
                historyAssetIds.forEach {
                    if let index = filteredSwapAssets.index(id: $0) {
                        historyAssets.append(filteredSwapAssets[index])
                    }
                }
                filteredSwapAssets.removeAll { historyAssetIds.contains($0.id) }
                var swapAssetsWithHistory = historyAssets
                swapAssetsWithHistory.append(contentsOf: filteredSwapAssets)

                state.$swapAssets.withLock { $0 = swapAssetsWithHistory }
                
                if let selectedContactChainId = state.selectedContact?.chainId,
                    let selectedAssetChainId = state.selectedAsset?.chain, selectedContactChainId != selectedAssetChainId {
                    state.selectedAsset = nil
                    return .concatenate(
                        .send(.selectedContactUpdated),
                        .send(.updateAssetsAccordingToSearchTerm)
                    )
                }

                return .send(.updateAssetsAccordingToSearchTerm)

            case .walletBalances:
                return .none
                
            // MARK: - Opt-in
                
            case .skipOptInTapped:
                state.optionOneChecked = false
                state.optionTwoChecked = false
                return .none
                
            case .confirmOptInTapped:
                return .none
                
            case .goBackForcedOptInTapped:
                return .none
                
            case .confirmForcedOptInTapped:
                return .none

            case .optionOneTapped:
                state.optionOneChecked.toggle()
                return .none

            case .optionTwoTapped:
                state.optionTwoChecked.toggle()
                return .none
                
                // MARK: - Addreess Book
                
            case .notInAddressBookButtonTapped:
                return .none

            case .addressBookTapped:
                return .none

            case .addressBookContactSelected(let address):
                state.selectedContact = state.addressBookContacts.contacts.first { $0.id == address }
                state.address = address
                return .send(.selectedContactUpdated)

            case .selectedContactClearTapped:
                state.selectedContact = nil
                state.address = ""
                return .send(.selectedContactUpdated)
                
            case .selectedContactUpdated:
                guard let chainId = state.selectedContact?.chainId else {
                    state.swapAssetsToPresent = state.swapAssets
                    return .none
                }
                let filteredSwapAssets = state.swapAssets.filter { $0.chain.lowercased() == chainId.lowercased() }
                state.swapAssetsToPresent = filteredSwapAssets
                if filteredSwapAssets.count == 1 {
                    state.selectedAsset = filteredSwapAssets.first
                } else if state.selectedAsset?.chain != chainId {
                    state.selectedAsset = nil
                }
                return .none

            case .addressBookUpdated:
                guard state.address.count >= 3 else {
                    state.isNotAddressInAddressBook = false
                    return .none
                }
                state.isNotAddressInAddressBook = true
                var isNotAddressInAddressBook = state.isNotAddressInAddressBook
                for contact in state.addressBookContacts.contacts {
                    if contact.id == state.address {
                        state.isNotAddressInAddressBook = false
                        isNotAddressInAddressBook = false
                        break
                    }
                }
                if isNotAddressInAddressBook {
                    state.isAddressBookHintVisible = true
                    return .run { send in
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        await send(.dismissAddressBookHint)
                    }
                    .cancellable(id: state.ABCancelId)
                } else {
                    state.isAddressBookHintVisible = false
                    return .cancel(id: state.ABCancelId)
                }
                
            case .dismissAddressBookHint:
                state.isAddressBookHintVisible = false
                return .none
                
            case .checkSelectedContact:
                let address = state.address
                state.selectedContact = state.addressBookContacts.contacts.first { $0.id == address }
                return .merge(
                    .send(.selectedContactUpdated),
                    .send(.addressBookUpdated)
                )
                
                // MARK: - Keystone
                
            case .confirmWithKeystoneTapped:
                state.isQuotePresented = false
                return .none
                
                // MARK: - CrossPay

            case .binding(\.amountAssetText):
                if !state.amountAssetText.isEmpty {
                    state.amountUsdText = state.payUsdLabel
                    state.amountText = state.payAssetLabel
                }
                return .none

            case .binding(\.amountUsdText):
                if !state.amountUsdText.isEmpty {
                    state.amountAssetText = state.payAssetLabel
                    state.amountText = state.payAssetLabel
                }
                return .none

            case .crossPayConfirmationRequired:
                return .none
                
            case .backFromConfirmationTapped:
                state.isQuoteRequestInFlight = false
                return .none

            case .binding:
                return .none
            }
        }
    }
}

// MARK: - Conversion Logic

extension SwapAndPay.State {
    public var zeroPlaceholder: String {
        return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
    }
    
    public var primaryLabelFrom: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            return amountText
        case (true, true):
            return amountText
        case (false, false):
            let amountInToken = (amount * selectedAsset.usdPrice) / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
        case (false, true):
            return amount.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var secondaryLabelFrom: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }
        
        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInUsd = amount * zecAsset.usdPrice
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (true, true):
            let amountIn = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountIn.simplified)) ?? "\(amountIn.simplified)"
        case (false, false):
            let amountInUsd = amount * selectedAsset.usdPrice
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, true):
            let amountIn = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountIn.simplified)) ?? "\(amountIn.simplified)"
        }
    }
    
    public var primaryLabelTo: String {
        guard let zecAsset else {
            return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return formatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInToken = (amount * zecAsset.usdPrice) / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
        case (true, true):
            return amount.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, false):
            return amountText
        case (false, true):
            return amountText
        }
    }
    
    public var secondaryLabelTo: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            let amountInUsd = amount * zecAsset.usdPrice
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (true, true):
            let amountInToken = amount / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
        case (false, false):
            let amountInUsd = amount * selectedAsset.usdPrice
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, true):
            let amountInToken = amount / selectedAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
        }
    }
    
    public var isZeroSpendable: Bool {
        walletBalancesState.shieldedBalance.decimalValue == 0
    }
    
    public var maxLabel: String {
        let amountInUsd: Decimal
        
        if isInputInUsd {
            guard let zecAsset else {
                return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
            }
            
            amountInUsd = walletBalancesState.shieldedBalance.decimalValue.roundedZec.decimalValue * zecAsset.usdPrice
        } else {
            amountInUsd = 0
        }

        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            return spendableBalance
        case (true, true):
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        case (false, false):
            return spendableBalance
        case (false, true):
            return amountInUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var zecToBeSpend: String {
        guard let zecAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }

        guard let selectedAsset else {
            return conversionFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
        }
        
        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            return amountText
        case (true, true):
            let amountInUsd = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd)) ?? "\(amountInUsd)"
        case (false, false):
            let amountInToken = (amount * selectedAsset.usdPrice) / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInToken)) ?? "\(amountInToken)"
        case (false, true):
            let amountInUsd = amount / zecAsset.usdPrice
            return conversionFormatter.string(from: NSDecimalNumber(decimal: amountInUsd)) ?? "\(amountInUsd)"
        }
    }
}

// MARK: - Quote

extension SwapAndPay.State {
    public var zecToBeSpendInQuote: String {
        guard let quote else {
            return "0"
        }
        
        let amount = quote.amountIn / Decimal(Zatoshi.Constants.oneZecInZatoshi)
        return conversionFormatter.string(from: NSDecimalNumber(decimal: amount.simplified)) ?? "\(amount)"
    }
    
    public var zecUsdToBeSpendInQuote: String {
        guard let quote else {
            return "0"
        }
        
        return quote.amountInUsd.localeUsd ?? "0"
    }
    
    public var tokenToBeReceivedInQuote: String {
        guard let quote else {
            return "0"
        }
        
        return conversionFormatter.string(from: NSDecimalNumber(decimal: quote.amountOut.simplified)) ?? "\(quote.amountOut.simplified)"
    }
    
    public var tokenUsdToBeReceivedInQuote: String {
        guard let quote else {
            return "0"
        }
        
        return quote.amountOutUsd.localeUsd ?? "0"
    }
    
    public var feeStr: String {
        guard let proposal else {
            return "0"
        }
        
        return proposal.totalFeeRequired().decimalString()
    }
    
    public var feeUsdStr: String {
        guard let proposal else {
            return "0"
        }
        
        guard let zecAsset else {
            return "0"
        }
        
        let feeIdUsd = (Decimal(proposal.totalFeeRequired().amount) / Decimal(Zatoshi.Constants.oneZecInZatoshi)) * zecAsset.usdPrice
        
        let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
            .precision(.fractionLength(4))

        return NSDecimalNumber(decimal: feeIdUsd).doubleValue.formatted(formatter)
    }
    
    public var totalZecToBeSpendInQuote: String {
        guard let quote else {
            return "0"
        }
        
        guard let proposal else {
            return "0"
        }
        
        let amount = (quote.amountIn + Decimal(proposal.totalFeeRequired().amount)) / Decimal(Zatoshi.Constants.oneZecInZatoshi)
        return conversionFormatter.string(from: NSDecimalNumber(decimal: amount.simplified)) ?? "\(amount)"
    }
    
    public var totalZecUsdToBeSpendInQuote: String {
        guard let quote else {
            return "0"
        }
        
        guard let proposal else {
            return "0"
        }
        
        guard let zecAsset else {
            return "0"
        }

        let totalAmount = (quote.amountIn + Decimal(proposal.totalFeeRequired().amount)) / Decimal(Zatoshi.Constants.oneZecInZatoshi)
        let totalAmountUsd = totalAmount * zecAsset.usdPrice
        return totalAmountUsd.formatted(.currency(code: CurrencyISO4217.usd.code))
    }
    
    public var zashiFeeStr: String {
        guard let quote else {
            return "0"
        }
        
        let zashiFeeCoeff = (Decimal(SwapAndPayClient.Constants.zashiFeeBps) / Decimal(10_000))
        let zashiFee = quote.amountIn * zashiFeeCoeff
        let zatoshi = Zatoshi(Int64(truncating: NSDecimalNumber(decimal: zashiFee)))

        return zatoshi.decimalString()
    }
    
    public var zashiFeeUsdStr: String {
        guard let quote else {
            return "0"
        }
        
        guard let zecAsset else {
            return "0"
        }

        let zashiFeeCoeff = (Decimal(SwapAndPayClient.Constants.zashiFeeBps) / Decimal(10_000))
        let zashiFee = ((quote.amountIn * zashiFeeCoeff) / Decimal(100_000_000)) * zecAsset.usdPrice

        if zashiFee < 0.01 {
            let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
                .precision(.fractionLength(4))
            
            return NSDecimalNumber(decimal: zashiFee).doubleValue.formatted(formatter)
        } else {
            return zashiFee.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var swapSlippageStr: String {
        guard let quote else {
            return "0"
        }
        
        guard let amountInUsdDecimal = quote.amountInUsd.localeUsdDecimal else {
            return "0"
        }

        guard let zecAsset else {
            return "0"
        }

        let swapCoeff: Decimal = isSwapExperienceEnabled ? 0.0 : 1.0
        let slippageDecimal = amountInUsdDecimal * slippage * 0.01 * swapCoeff
        let zatoshiDecimal = NSDecimalNumber(decimal: (slippageDecimal / zecAsset.usdPrice) * Decimal(Zatoshi.Constants.oneZecInZatoshi))
        let zatoshi = Zatoshi(Int64(zatoshiDecimal.doubleValue))

        return zatoshi.decimalString()
    }
    
    public var swapSlippageUsdStr: String {
        guard let quote else {
            return "0"
        }
        
        guard let amountInUsdDecimal = quote.amountInUsd.localeUsdDecimal else {
            return "0"
        }

        let swapCoeff: Decimal = isSwapExperienceEnabled ? 0.0 : 1.0
        let slippageDecimal = amountInUsdDecimal * slippage * 0.01 * swapCoeff
        
        if slippageDecimal < 0.01 {
            let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
                .precision(.fractionLength(4))
            
            return NSDecimalNumber(decimal: slippageDecimal).doubleValue.formatted(formatter)
        } else {
            return slippageDecimal.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var swapQuoteSlippageUsdStr: String {
        guard let quote else {
            return "0"
        }

        guard let selectedAsset else {
            return "0"
        }

        let slippageAmount = quote.amountOut * slippage * 0.01 * selectedAsset.usdPrice
        
        if slippageAmount < 0.01 {
            let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
                .precision(.fractionLength(4))
            
            return NSDecimalNumber(decimal: slippageAmount).doubleValue.formatted(formatter)
        } else {
            return slippageAmount.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var totalFees: Int64 {
        guard let proposal, let quote else {
            return 0
        }

        // transaction fee
        let transactionFee =  proposal.totalFeeRequired().amount
        
        // zashi fee
        let zashiFee = quote.amountIn * 0.005
        let zatoshiZashiFee = Int64(truncating: NSDecimalNumber(decimal: zashiFee))

        return transactionFee + zatoshiZashiFee
    }

    public var totalUSDFees: String {
        guard let zecAsset else {
            return "0.0"
        }

        let feeIdUsd = (Decimal(totalFees) / Decimal(Zatoshi.Constants.oneZecInZatoshi)) * zecAsset.usdPrice

        return NSDecimalNumber(decimal: feeIdUsd).doubleValue.formatted(.number.locale(Locale(identifier: "en_US")))
    }
    
    public var totalFeesStr: String {
        Zatoshi(totalFees).decimalString()
    }

    public var totalFeesUsdStr: String {
        guard let zecAsset else {
            return "0"
        }

        let totalFee = (Decimal(totalFees) / Decimal(Zatoshi.Constants.oneZecInZatoshi)) * zecAsset.usdPrice
        
        if totalFee < 0.01 {
            let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
                .precision(.fractionLength(4))
            
            return NSDecimalNumber(decimal: totalFee).doubleValue.formatted(formatter)
        } else {
            return totalFee.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
}

// MARK: - CrossPay

extension SwapAndPay.State {
    public var payZecLabel: String {
        guard let zecAsset else {
            return conversionCrossPayFormatter.string(from: NSNumber(value: 0.0)) ?? "0"
        }
        
        guard let selectedAsset else {
            return conversionCrossPayFormatter.string(from: NSNumber(value: 0.0)) ?? "0"
        }

        let amountInToken = (assetAmount * selectedAsset.usdPrice) / zecAsset.usdPrice
        return conversionCrossPayFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
    }
    
    public var payAssetLabel: String {
        guard let selectedAsset else {
            return conversionCrossPayFormatter.string(from: NSNumber(value: 0.0)) ?? "0"
        }

        let amountInToken = usdAmount / selectedAsset.usdPrice
        return conversionCrossPayFormatter.string(from: NSDecimalNumber(decimal: amountInToken.simplified)) ?? "\(amountInToken.simplified)"
    }
    
    public var payUsdLabel: String {
        guard let selectedAsset else {
            return conversionCrossPayFormatter.string(from: NSNumber(value: 0.0)) ?? "0"
        }

        let amountInUsd = assetAmount * selectedAsset.usdPrice
        return amountInUsd.formatted()
    }
}

// MARK: - String Representations

extension SwapAndPay.State {
    public var spendableBalance: String {
        formatter.string(from: walletBalancesState.shieldedBalance.decimalValue.roundedZec) ?? ""
    }
    
    public var slippageDiff: String? {
        guard let zecAsset else {
            return nil
        }
        
        guard let selectedAsset else {
            return nil
        }

        var amountInUsd: Decimal = 0
        
        switch (isSwapExperienceEnabled, isInputInUsd) {
        case (true, false):
            amountInUsd = amount * zecAsset.usdPrice
        case (true, true):
            amountInUsd = amount / zecAsset.usdPrice
        case (false, false):
            amountInUsd = amount * selectedAsset.usdPrice
        case (false, true):
            amountInUsd = amount / zecAsset.usdPrice
        }
        
        guard amountInUsd > 0 else {
            return nil
        }
        
        let amountInUsdWithSlippage = slippageInSheet * 0.01 * amountInUsd
        
        if amountInUsdWithSlippage < 0.01 {
            let formatter = FloatingPointFormatStyle<Double>.Currency(code: "USD")
                .precision(.fractionLength(4))
            
            return NSDecimalNumber(decimal: amountInUsdWithSlippage).doubleValue.formatted(formatter)
        } else {
            return amountInUsdWithSlippage.formatted(.currency(code: CurrencyISO4217.usd.code))
        }
    }
    
    public var localePlaceholder: String {
        usdFormatter.string(from: NSNumber(value: 0.0)) ?? "0.00"
    }
    
    public var rateToOneZec: String? {
        guard let selectedAsset else {
            return nil
        }
        
        guard let zecAsset else {
            return nil
        }
        
        let division = zecAsset.usdPrice / selectedAsset.usdPrice
        return conversionFormatter.string(from: NSDecimalNumber(decimal: division.simplified))
    }
    
    public func slippageString(value: Decimal) -> String {
        let value = slippageFormatter.string(from: NSDecimalNumber(decimal: value)) ?? ""
        
        return "\(value)%"
    }
    
    public var currentSlippageString: String {
        slippageString(value: slippage)
    }

    public var currentSlippageInSheetString: String {
        slippageString(value: slippageInSheet)
    }

    public var slippage05String: String {
        slippageString(value: 0.5)
    }

    public var slippage1String: String {
        slippageString(value: 1.0)
    }

    public var slippage2String: String {
        slippageString(value: 2.0)
    }
}

// MARK: - Formatters

extension SwapAndPay.State {
    public var usdFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter
    }
    
    public var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 8
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

    public var conversionCrossPayFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.usesGroupingSeparator = false
        formatter.locale = Locale.current
        
        return formatter
    }

    public var slippageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        
        return formatter
    }
}
