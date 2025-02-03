//
//  Tabs.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 09.10.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import UIKit

import AddressDetails
import Generated
import Receive
import BalanceBreakdown
import Home
import SendFlow
import Settings
import ZcashLightClientKit
import SendConfirmation
import Utils
import ExchangeRate
import CurrencyConversionSetup
import UserPreferencesStorage
import RequestZec
import ZecKeyboard
import AddressBook
import Models
import AddKeystoneHWWallet
import Scan
import TransactionsManager
import TransactionDetails
import ReadTransactionsStorage
import UserMetadataProvider

@Reducer
public struct Tabs {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case addressDetails
            case currencyConversionSetup
            case sendConfirmation
            case sendConfirmationKeystone
            case settings
        }

        public enum StackDestinationLowPrivacy: Int, Equatable {
            case zecKeyboard = 0
            case requestZecSummary
        }

        public enum StackDestinationMaxPrivacy: Int, Equatable {
            case zecKeyboard = 0
            case requestZec
            case requestZecSummary
        }

        public enum StackDestinationRequestPayment: Int, Equatable {
            case requestPaymentConfirmation = 0
            case addressBookNewContact
        }
        
        public enum StackDestinationAddKeystoneHWWallet: Int, Equatable {
            case addKeystoneHWWallet = 0
            case scan
            case accountSelection
        }

        public enum StackDestinationTransactions: Int, Equatable {
            case manager = 0
            case details
            case addressBook
        }

        public enum StackDestinationTransactionsHP: Int, Equatable {
            case details
            case addressBook
        }

        public enum Tab: Int, Equatable, CaseIterable {
            case account = 0
            case send
            case receive
            case balances
            
            public var title: String {
                switch self {
                case .account:
                    return L10n.Tabs.account
                case .send:
                    return L10n.Tabs.send
                case .receive:
                    return L10n.Tabs.receive
                case .balances:
                    return L10n.Tabs.balances
                }
            }
        }

        public var accountSwitchRequest = false
        public var addKeystoneHWWalletState: AddKeystoneHWWallet.State = .initial
        public var addressBookState: AddressBook.State = .initial
        public var addressDetailsState: AddressDetails.State
        public var balanceBreakdownState: Balances.State
        public var currencyConversionSetupState: CurrencyConversionSetup.State
        public var destination: Destination?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isInAppBrowserOn = false
        public var isRateEducationEnabled = false
        public var isRateTooltipEnabled = false
        public var homeState: Home.State
        public var receiveState: Receive.State
        public var requestZecState: RequestZec.State
        public var scanState: Scan.State = .initial
        public var selectedTab: Tab = .account
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var selectTextRequest = false
        public var sendConfirmationState: SendConfirmation.State
        public var sendState: SendFlow.State
        public var settingsState: Settings.State
        public var stackDestinationAddKeystoneHWWallet: StackDestinationAddKeystoneHWWallet?
        public var stackDestinationAddKeystoneHWWalletBindingsAlive = 0
        public var stackDestinationLowPrivacy: StackDestinationLowPrivacy?
        public var stackDestinationLowPrivacyBindingsAlive = 0
        public var stackDestinationMaxPrivacy: StackDestinationMaxPrivacy?
        public var stackDestinationMaxPrivacyBindingsAlive = 0
        public var stackDestinationRequestPayment: StackDestinationRequestPayment?
        public var stackDestinationRequestPaymentBindingsAlive = 0
        public var stackDestinationTransactions: StackDestinationTransactions?
        public var stackDestinationTransactionsBindingsAlive = 0
        public var stackDestinationTransactionsHP: StackDestinationTransactionsHP?
        public var stackDestinationTransactionsHPBindingsAlive = 0
        public var textToSelect = ""
        public var transactionDetailsState: TransactionDetails.State = .initial
        @Shared(.inMemory(.transactionMemos)) public var transactionMemos: [String: [String]] = [:]
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        public var transactionsManagerState: TransactionsManager.State = .initial
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        public var zecKeyboardState: ZecKeyboard.State
        
        public var inAppBrowserURL: String {
            "https://keyst.one/shop/products/keystone-3-pro?discount=Zashi"
        }

        public init(
            addressDetailsState: AddressDetails.State = .initial,
            balanceBreakdownState: Balances.State,
            currencyConversionSetupState: CurrencyConversionSetup.State,
            destination: Destination? = nil,
            isRateEducationEnabled: Bool = false,
            isRateTooltipEnabled: Bool = false,
            homeState: Home.State,
            receiveState: Receive.State,
            requestZecState: RequestZec.State,
            selectedTab: Tab = .account,
            sendConfirmationState: SendConfirmation.State,
            sendState: SendFlow.State,
            settingsState: Settings.State,
            zecKeyboardState: ZecKeyboard.State
        ) {
            self.addressDetailsState = addressDetailsState
            self.balanceBreakdownState = balanceBreakdownState
            self.currencyConversionSetupState = currencyConversionSetupState
            self.destination = destination
            self.isRateEducationEnabled = isRateEducationEnabled
            self.isRateTooltipEnabled = isRateTooltipEnabled
            self.homeState = homeState
            self.receiveState = receiveState
            self.requestZecState = requestZecState
            self.selectedTab = selectedTab
            self.sendConfirmationState = sendConfirmationState
            self.sendState = sendState
            self.settingsState = settingsState
            self.zecKeyboardState = zecKeyboardState
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case accountSwitchTapped
        case addKeystoneHWWalletTapped
        case addKeystoneHWWallet(AddKeystoneHWWallet.Action)
        case addressBook(AddressBook.Action)
        case addressDetails(AddressDetails.Action)
        case balanceBreakdown(Balances.Action)
        case binding(BindingAction<Tabs.State>)
        case currencyConversionCloseTapped
        case currencyConversionSetup(CurrencyConversionSetup.Action)
        case dismissSelectTextEditor
        case home(Home.Action)
        case keystoneBannerTapped
        case onAppear
        case presentKeystoneWeb
        case rateTooltipTapped
        case receive(Receive.Action)
        case requestZec(RequestZec.Action)
        case scan(Scan.Action)
        case selectedTabChanged(State.Tab)
        case send(SendFlow.Action)
        case sendConfirmation(SendConfirmation.Action)
        case settings(Settings.Action)
        case transactionDetails(TransactionDetails.Action)
        case transactionsManager(TransactionsManager.Action)
        case updateDestination(Tabs.State.Destination?)
        case updateStackDestinationAddKeystoneHWWallet(Tabs.State.StackDestinationAddKeystoneHWWallet?)
        case updateStackDestinationLowPrivacy(Tabs.State.StackDestinationLowPrivacy?)
        case updateStackDestinationMaxPrivacy(Tabs.State.StackDestinationMaxPrivacy?)
        case updateStackDestinationRequestPayment(Tabs.State.StackDestinationRequestPayment?)
        case updateStackDestinationTransactions(Tabs.State.StackDestinationTransactions?)
        case updateStackDestinationTransactionsHP(Tabs.State.StackDestinationTransactionsHP?)
        case walletAccountTapped(WalletAccount)
        case zecKeyboard(ZecKeyboard.Action)
    }

    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.userStoredPreferences) var userStoredPreferences

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }

        Scope(state: \.addKeystoneHWWalletState, action: \.addKeystoneHWWallet) {
            AddKeystoneHWWallet()
        }
        
        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }

        Scope(state: \.sendState, action: \.send) {
            SendFlow()
        }

        Scope(state: \.sendConfirmationState, action: \.sendConfirmation) {
            SendConfirmation()
        }

        Scope(state: \.receiveState, action: \.receive) {
            Receive()
        }

        Scope(state: \.requestZecState, action: \.requestZec) {
            RequestZec()
        }

        Scope(state: \.currencyConversionSetupState, action: \.currencyConversionSetup) {
            CurrencyConversionSetup()
        }

        Scope(state: \.balanceBreakdownState, action: \.balanceBreakdown) {
            Balances()
        }

        Scope(state: \.homeState, action: \.home) {
            Home()
        }

        Scope(state: \.settingsState, action: \.settings) {
            Settings()
        }

        Scope(state: \.addressDetailsState, action: \.addressDetails) {
            AddressDetails()
        }

        Scope(state: \.zecKeyboardState, action: \.zecKeyboard) {
            ZecKeyboard()
        }
        
        Scope(state: \.transactionsManagerState, action: \.transactionsManager) {
            TransactionsManager()
        }

        Scope(state: \.transactionDetailsState, action: \.transactionDetails) {
            TransactionDetails()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.scanState.instructions = L10n.Keystone.scanInfo
                state.scanState.forceLibraryToHide = true
                state.isRateEducationEnabled = userStoredPreferences.exchangeRate() == nil
                return .none
                
            case .accountSwitchTapped:
                state.accountSwitchRequest.toggle()
                return .none
                
            case .addKeystoneHWWalletTapped:
                state.accountSwitchRequest = false
                state.scanState.checkers = [.keystoneScanChecker]
                return .send(.updateStackDestinationAddKeystoneHWWallet(.addKeystoneHWWallet))
                
            case .walletAccountTapped(let walletAccount):
                state.$selectedWalletAccount.withLock { $0 = walletAccount }
                state.accountSwitchRequest = false
                state.homeState.transactionListState.isInvalidated = true
                state.receiveState.currentFocus = .uaAddress
                return .concatenate(
                    .send(.home(.walletBalances(.updateBalances))),
                    .send(.send(.walletBalances(.updateBalances))),
                    .send(.balanceBreakdown(.walletBalances(.updateBalances))),
                    .send(.transactionsManager(.resetFiltersTapped))
                )
            
            case .addKeystoneHWWallet(.continueTapped):
                return .send(.updateStackDestinationAddKeystoneHWWallet(.scan))

            case .addKeystoneHWWallet(.forgetThisDeviceTapped):
                return .send(.updateStackDestinationAddKeystoneHWWallet(nil))
                
            case .addKeystoneHWWallet:
                return .none

            case let .receive(.addressDetailsRequest(address, maxPrivacy)):
                state.addressDetailsState.address = address
                state.addressDetailsState.maxPrivacy = maxPrivacy
                if state.selectedWalletAccount?.vendor == .keystone {
                    state.addressDetailsState.addressTitle = maxPrivacy
                    ? L10n.Accounts.Keystone.shieldedAddress
                    : L10n.Accounts.Keystone.transparentAddress
                } else {
                    state.addressDetailsState.addressTitle = maxPrivacy
                    ? L10n.Accounts.Zashi.shieldedAddress
                    : L10n.Accounts.Zashi.transparentAddress
                }
                return .send(.updateDestination(.addressDetails))

            case let .receive(.requestTapped(address, maxPrivacy)):
                state.zecKeyboardState.input = "0"
                state.requestZecState.address = address
                state.requestZecState.maxPrivacy = maxPrivacy
                state.requestZecState.memoState = .initial
                if maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.zecKeyboard))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(.zecKeyboard))
                }

            case .zecKeyboard(.nextTapped):
                state.requestZecState.requestedZec = state.zecKeyboardState.amount
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.requestZec))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(.requestZecSummary))
                }
                
            case .requestZec(.requestTapped):
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.requestZecSummary))
                }
                return .none
                
            case .requestZec(.cancelRequestTapped):
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(nil))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(nil))
                }
                
            case .sendConfirmation(.saveAddressTapped(let address)):
                state.addressBookState.address = address.data
                state.addressBookState.name = ""
                state.addressBookState.isValidZcashAddress = true
                state.addressBookState.isNameFocused = true
                return .send(.updateStackDestinationRequestPayment(.addressBookNewContact))

            case .addressBook(.saveButtonTapped):
                if state.stackDestinationTransactions == .addressBook {
                    return .send(.updateStackDestinationTransactions(.details))
                } else if state.stackDestinationTransactionsHP == .addressBook {
                    return .send(.updateStackDestinationTransactionsHP(.details))
                }
                return .send(.updateStackDestinationRequestPayment(.requestPaymentConfirmation))

            case .home(.seeAllTransactionsTapped):
                return .send(.updateStackDestinationTransactions(.manager))
                
            case .home(.walletBalances(.exchangeRateRefreshTapped)), .send(.walletBalances(.exchangeRateRefreshTapped)), .balanceBreakdown(.walletBalances(.exchangeRateRefreshTapped)):
                if state.isRateTooltipEnabled {
                    state.isRateTooltipEnabled = false
                    return .none
                }
                state.isRateTooltipEnabled = state.homeState.walletBalancesState.isExchangeRateStale
                return .none

            case .addressBook:
                return .none

            case .addressDetails:
                return .none

            case .binding:
                return .none
                
            case .receive:
                return .none
            
            case .requestZec:
                return .none
                
            case .balanceBreakdown(.shieldFundsWithKeystone):
                state.scanState.checkers = [.keystonePCZTScanChecker]
                return .none
                
            case .balanceBreakdown(.shieldFundsSuccess):
                return .none
            
            case .balanceBreakdown(.proposalReadyForShieldingWithKeystone(let proposal)):
                state.sendConfirmationState.proposal = proposal
                state.sendConfirmationState.isShielding = true
                return .concatenate(
                    .send(.updateDestination(.sendConfirmationKeystone)),
                    .send(.sendConfirmation(.resolvePCZT))
                    )
                
            case .balanceBreakdown:
                return .none

            case .currencyConversionCloseTapped:
                state.isRateEducationEnabled = false
                try? userStoredPreferences.setExchangeRate(UserPreferencesStorage.ExchangeRate(manual: true, automatic: false))
                return .none
                
            case .currencyConversionSetup(.enableTapped), .currencyConversionSetup(.skipTapped):
                state.isRateEducationEnabled = false
                return .send(.updateDestination(nil))
                
            case .currencyConversionSetup:
                return .none
                
            case .home(.walletBalances(.availableBalanceTapped)),
                .send(.walletBalances(.availableBalanceTapped)):
                state.selectedTab = .balances
                return .none

            case .home(.makeATransactionTapped):
                state.selectedTab = .send
                return .none

            case .dismissSelectTextEditor:
                state.selectTextRequest = false
                return .none

            case .settings(.advancedSettings(.currencyConversionSetup(.saveChangesTapped))):
                return .send(.send(.exchangeRateSetupChanged))
                
            case .send(.confirmationRequired(let type)):
                state.sendConfirmationState.amount = state.sendState.amount
                state.sendConfirmationState.address = state.sendState.address.data
                state.sendConfirmationState.isShielding = false
                state.sendConfirmationState.proposal = state.sendState.proposal
                state.sendConfirmationState.feeRequired = state.sendState.feeRequired
                state.sendConfirmationState.message = state.sendState.message
                state.sendConfirmationState.currencyAmount = state.sendState.currencyConversion?.convert(state.sendState.amount).redacted ?? .empty
                if type == .send {
                    return .send(.updateDestination(.sendConfirmation))
                } else {
                    return .send(.updateStackDestinationRequestPayment(.requestPaymentConfirmation))
                }
                                
            case .send:
                return .none

            case .sendConfirmation(.sendPartial):
                state.selectedTab = .send
                return .none

            case .sendConfirmation(.viewTransactionTapped):
                if let txid = state.sendConfirmationState.txIdToExpand {
                    if let index = state.transactions.index(id: txid) {
                        state.sendConfirmationState.transactionDetailsState.transaction = state.transactions[index]
                        state.sendConfirmationState.transactionDetailsState.isCloseButtonRequired = true
                        return .send(.sendConfirmation(.updateStackDestinationTransactions(.details)))
                    }
                }
                return .none

            case .sendConfirmation(.transactionDetails(.closeDetailTapped)):
                state.selectedTab = .account
                state.sendConfirmationState.stackDestinationBindingsAlive = 0
                return .concatenate(
                    .send(.updateDestination(nil)),
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
                    .send(.sendConfirmation(.updateStackDestination(nil))),
                    .send(.sendConfirmation(.updateStackDestinationTransactions(nil))),
                    .send(.send(.resetForm))
                )

            case .sendConfirmation(.backFromFailurePressed):
                state.sendConfirmationState.stackDestinationBindingsAlive = 0
                return .concatenate(
                    .send(.updateDestination(nil)),
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
                    .send(.sendConfirmation(.updateStackDestination(nil)))
                )

            case .sendConfirmation(.backFromPCZTFailurePressed):
                state.sendConfirmationState.stackDestinationBindingsAlive = 0
                state.destination = nil
                state.sendConfirmationState.scanFailedPreScanBinding = false
                state.sendConfirmationState.scanFailedDuringScanBinding = false
                return .concatenate(
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
                    .send(.sendConfirmation(.updateStackDestination(nil)))
                )

            case .sendConfirmation(.closeTapped):
                state.selectedTab = .account
                state.sendConfirmationState.stackDestinationBindingsAlive = 0
                return .concatenate(
                    .send(.updateDestination(nil)),
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
                    .send(.sendConfirmation(.updateStackDestination(nil))),
                    .send(.send(.resetForm))
                )
                
            case .sendConfirmation(.partialProposalError(.dismiss)):
                return .run { send in
                    await send(.updateDestination(nil))
                    try? await mainQueue.sleep(for: .seconds(0.5))
                    await send(.sendConfirmation(.partialProposalErrorDismiss))
                }

            case .sendConfirmation(.goBackPressed):
                return .send(.updateDestination(nil))

            case .sendConfirmation(.goBackPressedFromRequestZec):
                state.sendState.address = .empty
                state.sendState.memoState.text = ""
                state.sendState.zecAmountText = .empty
                state.sendState.currencyText = .empty
                return .send(.updateStackDestinationRequestPayment(nil))

            case .sendConfirmation(.rejectTapped):
                state.sendConfirmationState.stackDestinationBindingsAlive = 0
                return .concatenate(
                    .send(.send(.resetForm)),
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.updateDestination(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
                    .send(.sendConfirmation(.updateStackDestination(nil)))
                )

            case .sendConfirmation:
                return .none

            case .settings:
                return .none

            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                if tab == .send {
                    exchangeRate.refreshExchangeRateUSD()
                }
                state.isRateTooltipEnabled = false
                return .none
                
            case .updateDestination(.currencyConversionSetup):
                state.destination = .currencyConversionSetup
                return .send(.currencyConversionCloseTapped)
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .updateStackDestinationAddKeystoneHWWallet(let destination):
                if let destination {
                    state.stackDestinationAddKeystoneHWWalletBindingsAlive = destination.rawValue
                }
                state.stackDestinationAddKeystoneHWWallet = destination
                return .none

            case .updateStackDestinationLowPrivacy(let destination):
                if let destination {
                    state.stackDestinationLowPrivacyBindingsAlive = destination.rawValue
                }
                state.stackDestinationLowPrivacy = destination
                return .none

            case .updateStackDestinationMaxPrivacy(let destination):
                if let destination {
                    state.stackDestinationMaxPrivacyBindingsAlive = destination.rawValue
                }
                state.stackDestinationMaxPrivacy = destination
                return .none

            case .updateStackDestinationRequestPayment(let destination):
                if let destination {
                    state.stackDestinationRequestPaymentBindingsAlive = destination.rawValue
                }
                state.stackDestinationRequestPayment = destination
                return .none

            case .updateStackDestinationTransactions(let destination):
                if let destination {
                    state.stackDestinationTransactionsBindingsAlive = destination.rawValue
                }
                state.stackDestinationTransactions = destination
                return .none
                
            case .updateStackDestinationTransactionsHP(let destination):
                if let destination {
                    state.stackDestinationTransactionsHPBindingsAlive = destination.rawValue
                }
                state.stackDestinationTransactionsHP = destination
                return .none

            case .rateTooltipTapped:
                state.isRateTooltipEnabled = false
                return .none
                
            case .zecKeyboard:
                return .none

            case .scan(.cancelPressed):
                return .send(.updateStackDestinationAddKeystoneHWWallet(.addKeystoneHWWallet))

            case .scan(.foundZA(let zcashAccounts)):
                if state.addKeystoneHWWalletState.zcashAccounts == nil {
                    state.addKeystoneHWWalletState.zcashAccounts = zcashAccounts
                    return .send(.updateStackDestinationAddKeystoneHWWallet(.accountSelection))
                }
                return .none
                
            case .scan:
                return .none
                
            case .keystoneBannerTapped:
                return .run { send in
                    await send(.accountSwitchTapped)
                    try? await mainQueue.sleep(for: .seconds(1))
                    await send(.presentKeystoneWeb)
                }
                
            case .presentKeystoneWeb:
                state.isInAppBrowserOn = true
                return .none
                
            case .home(.transactionList(.transactionTapped(let txId))):
                if let index = state.transactions.index(id: txId) {
                    state.transactionDetailsState.transaction = state.transactions[index]
                    return .send(.updateStackDestinationTransactionsHP(.details))
                }
                return .none

            case .transactionsManager(.transactionTapped(let txId)):
                if let index = state.transactions.index(id: txId) {
                    state.transactionDetailsState.transaction = state.transactions[index]
                    return .send(.updateStackDestinationTransactions(.details))
                }
                return .none

            case .transactionDetails(.saveAddressTapped):
                state.addressBookState.address = state.transactionDetailsState.transaction.address
                state.addressBookState.originalAddress = state.addressBookState.address
                state.addressBookState.isNameFocused = true
                state.addressBookState.isValidZcashAddress = true
                if state.stackDestinationTransactions == .details {
                    return .send(.updateStackDestinationTransactions(.addressBook))
                } else if state.stackDestinationTransactionsHP == .details {
                    return .send(.updateStackDestinationTransactionsHP(.addressBook))
                }
                return .none

            case .transactionDetails(.sendAgainTapped):
                state.stackDestinationTransactions = nil
                state.stackDestinationTransactionsHP = nil
                state.sendState.address = state.transactionDetailsState.transaction.address.redacted
                state.sendState.memoState.text = state.transactionMemos[state.transactionDetailsState.transaction.id]?.first ?? ""
                let zecAmount = state.transactionDetailsState.transaction.zecAmount.decimalString().redacted
                return .run { send in
                    await send(.send(.zecAmountUpdated(zecAmount)))
                    await send(.send(.validateAddress))
                    try await mainQueue.sleep(for: .seconds(0.1))
                    await send(.selectedTabChanged(.send))
                }

            case .transactionDetails(.bookmarkTapped):
                return .send(.transactionsManager(.updateTransactionsAccordingToSearchTerm))
                
            case .transactionsManager:
                return .none
                
            case .transactionDetails:
                return .none

            case .home:
                return .none
            }
        }
    }
}
