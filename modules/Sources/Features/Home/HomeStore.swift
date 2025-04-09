import UIKit
import SwiftUI
import AVFoundation
import ComposableArchitecture
import ZcashLightClientKit
import Utils
import Models
import Generated
import ReviewRequest
import TransactionList
import Scan
import SyncProgress
import WalletBalances
import PartnerKeys
import UserPreferencesStorage
import Utils
import BalanceBreakdown
import SmartBanner
import ShieldingProcessor

@Reducer
public struct Home {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    @ObservableState
    public struct State: Equatable {
        public var accountSwitchRequest = false
        @Presents public var alert: AlertState<Action>?
        public var appId: String?
        public var balancesBinding = false
        public var balancesState = Balances.State.initial
        public var canRequestReview = false
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isInAppBrowserCoinbaseOn = false
        public var isInAppBrowserKeystoneOn = false
        public var isRateEducationEnabled = false
        public var isRateTooltipEnabled = false
        public var migratingDatabase = true
        public var moreRequest = false
        public var shieldingProcessorState = ShieldingProcessor.State()
        public var smartBannerState = SmartBanner.State.initial
        public var syncProgressState: SyncProgress.State
        public var walletConfig: WalletConfig
//        public var scanBinding = false
//        public var scanState = Scan.State.initial
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var transactionListState: TransactionList.State
        public var uAddress: UnifiedAddress? = nil
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        public var walletBalancesState: WalletBalances.State

        public var isKeystoneConnected: Bool {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return true
                }
            }
            
            return false
        }

        public var inAppBrowserURLCoinbase: String? {
            if let address = try? uAddress?.transparentReceiver().stringEncoded, let appId {
                return L10n.Partners.coinbaseOnrampUrl(appId, address)
            }
            
            return nil
        }
        
        public var inAppBrowserURLKeystone: String {
            "https://keyst.one/shop/products/keystone-3-pro?discount=Zashi"
        }

        public init(
            canRequestReview: Bool = false,
            migratingDatabase: Bool = true,
            syncProgressState: SyncProgress.State,
            transactionListState: TransactionList.State,
            walletBalancesState: WalletBalances.State,
            walletConfig: WalletConfig
        ) {
            self.canRequestReview = canRequestReview
            self.migratingDatabase = migratingDatabase
            self.syncProgressState = syncProgressState
            self.transactionListState = transactionListState
            self.walletConfig = walletConfig
            self.walletBalancesState = walletBalancesState
        }
    }

    public enum Action: BindableAction, Equatable {
        case debug
        
        case accountSwitchTapped
        case addKeystoneHWWalletTapped
        case alert(PresentationAction<Action>)
        case balances(Balances.Action)
        case balancesBindingUpdated(Bool)
        case binding(BindingAction<Home.State>)
        case currencyConversionCloseTapped
        case currencyConversionSetupTapped
        case foundTransactions
        case getSomeZecTapped
        case keystoneBannerTapped
        case moreTapped
        case onAppear
        case onDisappear
        case presentKeystoneWeb
        case rateTooltipTapped
        case receiveTapped
        case resolveReviewRequest
        case retrySync
        case reviewRequestFinished
//        case scan(Scan.Action)
        case scanTapped
        case seeAllTransactionsTapped
        case sendTapped
        case settingsTapped
        case shieldingProcessor(ShieldingProcessor.Action)
        case showSynchronizerErrorAlert(ZcashError)
        case smartBanner(SmartBanner.Action)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case syncFailed(ZcashError)
        case syncProgress(SyncProgress.Action)
        case updateTransactionList([TransactionState])
        case transactionList(TransactionList.Action)
        case walletAccountTapped(WalletAccount)
        case walletBalances(WalletBalances.Action)
        
        // more actions
        case coinbaseTapped
        case flexaTapped
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.transactionListState, action: \.transactionList) {
            TransactionList()
        }

        Scope(state: \.shieldingProcessorState, action: \.shieldingProcessor) {
            ShieldingProcessor()
        }

//        Scope(state: \.scanState, action: \.scan) {
//            Scan()
//        }

        Scope(state: \.syncProgressState, action: \.syncProgress) {
            SyncProgress()
        }

        Scope(state: \.walletBalancesState, action: \.walletBalances) {
            WalletBalances()
        }

        Scope(state: \.balancesState, action: \.balances) {
            Balances()
        }

        Scope(state: \.smartBannerState, action: \.smartBanner) {
            SmartBanner()
        }

        Reduce { state, action in
            switch action {
            case .debug:
                return .send(.smartBanner(.debug))
                
            case .onAppear:
//                state.scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                state.appId = PartnerKeys.cbProjectId
                state.walletBalancesState.migratingDatabase = state.migratingDatabase
                state.migratingDatabase = false
                state.isRateEducationEnabled = userStoredPreferences.exchangeRate() == nil
                return .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions = $0 {
                                    return Home.Action.foundTransactions
                                }
                                return nil
                            }
                    }
                    .cancellable(id: CancelEventId, cancelInFlight: true)
                
            case .onDisappear:
                return .concatenate(
                    .cancel(id: CancelStateId),
                    .cancel(id: CancelEventId)
                )
                
            case .receiveTapped, .sendTapped:
                return .none
                
            case .scanTapped:
//                state.scanBinding = true
                return .none

            case .moreTapped:
                state.moreRequest = true
                return .none

            case .resolveReviewRequest:
                if reviewRequest.canRequestReview() {
                    state.canRequestReview = true
                    return .run { _ in
                        reviewRequest.reviewRequested()
                    }
                }
                return .none
                
            case .reviewRequestFinished:
                state.canRequestReview = false
                return .none

            case .getSomeZecTapped:
                return .none
                
            case .seeAllTransactionsTapped:
                return .none
                
            case .updateTransactionList:
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)
                switch snapshot.syncStatus {
                case .error(let error):
                    return .send(.showSynchronizerErrorAlert(error.toZcashError()))

                case .upToDate:
                    return .run { _ in
                        reviewRequest.syncFinished()
                    }

                default:
                    return .none
                }

            case .syncProgress:
                return .none

            case .foundTransactions:
                return .run { _ in
                    reviewRequest.foundTransactions()
                }
                
            case .transactionList:
                return .none
                
            case .retrySync:
                return .run { send in
                    do {
                        try await sdkSynchronizer.start(true)
                    } catch {
                        await send(.syncFailed(error.toZcashError()))
                    }
                }

            case .currencyConversionCloseTapped:
                state.isRateEducationEnabled = false
                try? userStoredPreferences.setExchangeRate(UserPreferencesStorage.ExchangeRate(manual: true, automatic: false))
                return .none

            case .rateTooltipTapped:
                state.isRateTooltipEnabled = false
                return .none

            case .showSynchronizerErrorAlert:
                return .none
                
            case .syncFailed:
                return .none

            case .walletBalances(.exchangeRateRefreshTapped):
                if state.isRateTooltipEnabled {
                    state.isRateTooltipEnabled = false
                    return .none
                }
                state.isRateTooltipEnabled = state.walletBalancesState.isExchangeRateStale
                return .none

            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

//            case .scan(.cancelTapped):
//                state.scanBinding = false
//                return .none
                
            case .alert:
                return .none
                
            case .settingsTapped:
                return .none
                
            case .binding:
                return .none
                
            case .currencyConversionSetupTapped:
                return .none

//            case .scan:
//                return .none

                // Accounts
                
            case .accountSwitchTapped:
                state.accountSwitchRequest.toggle()
                return .none

            case .addKeystoneHWWalletTapped:
                state.accountSwitchRequest = false
                state.moreRequest = false
                return .none

            case .keystoneBannerTapped:
                state.accountSwitchRequest = false
                return .run { send in
                    try? await mainQueue.sleep(for: .seconds(1))
                    await send(.presentKeystoneWeb)
                }

            case .presentKeystoneWeb:
                state.isInAppBrowserKeystoneOn = true
                return .none

            case .walletAccountTapped:
                state.accountSwitchRequest = false
                return .none
//                guard state.selectedWalletAccount != walletAccount else {
//                    return .none
//                }
//                state.$selectedWalletAccount.withLock { $0 = walletAccount }
//                return .send(.smartBanner(.walletAccountChanged))
                //state.homeState.transactionListState.isInvalidated = true
//                state.receiveState.currentFocus = .uaAddress
//                return .concatenate(
//                    .send(.home(.walletBalances(.updateBalances))),
//                    .send(.send(.walletBalances(.updateBalances))),
//                    .send(.balanceBreakdown(.walletBalances(.updateBalances))),
//                    .send(.transactionsManager(.resetFiltersTapped))
//                )
//                return .none
                
                // Smart Banner

            case .smartBanner(.currencyConversionScreenRequested):
                return .send(.currencyConversionSetupTapped)
                
            case .smartBanner(.shieldTapped):
                return .send(.shieldingProcessor(.shieldFunds))

                // Shielding processor

            case .shieldingProcessor(.shieldFundsFailure(let error)):
                state.alert = AlertState.shieldFundsFailure(error)
                return .none
                
                // More actions
            case .coinbaseTapped:
                state.moreRequest = false
                state.isInAppBrowserCoinbaseOn = true
                return .none
                
            case .flexaTapped:
                return .none
            
            case .walletBalances(.availableBalanceTapped):
                state.balancesBinding = true
                return .none
                
            case .balancesBindingUpdated(let newState):
                state.balancesBinding = newState
                return .none

            case .balances:
                return .none
                
            case .walletBalances:
                return .none
                
            case .smartBanner:
                return .none
                
            case .shieldingProcessor:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == Home.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.detailedMessage))
        }
    }
}
