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
import RestoreWalletStorage

public typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
public typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

public struct HomeReducer: Reducer {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var canRequestReview = false
        public var isRestoringWallet = false
        public var requiredTransactionConfirmations = 0
        public var scanState: Scan.State
        public var shieldedBalance: Zatoshi
        public var shieldedWithPendingBalance: Zatoshi
        public var synchronizerStatusSnapshot: SyncStatusSnapshot
        public var syncProgressState: SyncProgressReducer.State
        public var walletConfig: WalletConfig
        public var totalBalance: Zatoshi
        public var transactionListState: TransactionListReducer.State
        public var transparentBalance: Zatoshi
        public var migratingDatabase = true
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/Electric-Coin-Company/zashi-ios/issues/311
        public var zecPrice = Decimal(140.0)

        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.decimalValue.decimalValue * zecPrice)
        }

        public var isSendButtonDisabled: Bool {
            shieldedBalance.amount == 0
        }
        
        public var isProcessingZeroAvailableBalance: Bool {
            if shieldedBalance.amount == 0 && transparentBalance.amount > 0 {
                return false
            }
            
            return totalBalance.amount != shieldedBalance.amount && shieldedBalance.amount == 0
        }

        public init(
            canRequestReview: Bool = false,
            isRestoringWallet: Bool = false,
            requiredTransactionConfirmations: Int = 0,
            scanState: Scan.State,
            shieldedBalance: Zatoshi,
            shieldedWithPendingBalance: Zatoshi = .zero,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            syncProgressState: SyncProgressReducer.State,
            totalBalance: Zatoshi = .zero,
            transactionListState: TransactionListReducer.State,
            transparentBalance: Zatoshi = .zero,
            walletConfig: WalletConfig,
            zecPrice: Decimal = Decimal(140.0)
        ) {
            self.canRequestReview = canRequestReview
            self.isRestoringWallet = isRestoringWallet
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.shieldedWithPendingBalance = shieldedWithPendingBalance
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.syncProgressState = syncProgressState
            self.totalBalance = totalBalance
            self.transactionListState = transactionListState
            self.transparentBalance = transparentBalance
            self.walletConfig = walletConfig
            self.zecPrice = zecPrice
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case balanceBreakdown
        case debugMenuStartup
        case foundTransactions
        case onAppear
        case onDisappear
        case resolveReviewRequest
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case retrySync
        case reviewRequestFinished
        case showSynchronizerErrorAlert(ZcashError)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case syncFailed(ZcashError)
        case syncProgress(SyncProgressReducer.Action)
        case updateTransactionList([TransactionState])
        case transactionList(TransactionListReducer.Action)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.transactionListState, action: /Action.transactionList) {
            TransactionListReducer()
        }

        Scope(state: \.syncProgressState, action: /Action.syncProgress) {
            SyncProgressReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations
                return .merge(
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { $0.redacted }
                            .map(HomeReducer.Action.synchronizerStateChanged)
                    }
                    .cancellable(id: CancelStateId, cancelInFlight: true),
                    .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions = $0 {
                                    return HomeReducer.Action.foundTransactions
                                }
                                return nil
                            }
                    }
                    .cancellable(id: CancelEventId, cancelInFlight: true)
                )
                
            case .onDisappear:
                return .concatenate(
                    .cancel(id: CancelStateId),
                    .cancel(id: CancelEventId)
                )

            case .resolveReviewRequest:
                if reviewRequest.canRequestReview() {
                    state.canRequestReview = true
                    return .run { _ in
                        reviewRequest.reviewRequested()
                    }
                }
                return .none
                
            case .restoreWalletTask:
                return .run { send in
                    for await value in await restoreWalletStorage.value() {
                        await send(.restoreWalletValue(value))
                    }
                }

            case .restoreWalletValue(let value):
                state.isRestoringWallet = value
                return .none

            case .reviewRequestFinished:
                state.canRequestReview = false
                return .none
                                
            case .updateTransactionList:
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)

                if snapshot.syncStatus != .unprepared {
                    state.migratingDatabase = false
                }

                state.synchronizerStatusSnapshot = snapshot
                let accountBalance = latestState.data.accountBalance?.data
                
                state.shieldedBalance = (accountBalance?.saplingBalance.spendableValue ?? .zero) + (accountBalance?.orchardBalance.spendableValue ?? .zero)
                state.shieldedWithPendingBalance = (accountBalance?.saplingBalance.total() ?? .zero) + (accountBalance?.orchardBalance.total() ?? .zero)
                state.transparentBalance = accountBalance?.unshielded ?? .zero
                state.totalBalance = state.shieldedWithPendingBalance + state.transparentBalance

                switch snapshot.syncStatus {
                case .error(let error):
                    return Effect.send(.showSynchronizerErrorAlert(error.toZcashError()))

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

            case .showSynchronizerErrorAlert:
                return .none
                
            case .debugMenuStartup:
                return .none
                
            case .syncFailed:
                return .none

            case .balanceBreakdown:
                return .none
                
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none
            }
        }
    }
}

// MARK: - Store

extension HomeStore {
    func historyStore() -> TransactionListStore {
        self.scope(
            state: \.transactionListState,
            action: HomeReducer.Action.transactionList
        )
    }
}

// MARK: Placeholders

extension HomeReducer.State {
    public static var initial: Self {
        .init(
            scanState: .initial,
            shieldedBalance: .zero,
            synchronizerStatusSnapshot: .initial,
            syncProgressState: .initial,
            transactionListState: .initial,
            walletConfig: .initial
        )
    }
}

extension HomeStore {
    public static var placeholder: HomeStore {
        HomeStore(
            initialState: .initial
        ) {
            HomeReducer()
        }
    }

    public static var error: HomeStore {
        HomeStore(
            initialState: .init(
                scanState: .initial,
                shieldedBalance: .zero,
                synchronizerStatusSnapshot: .snapshotFor(
                    state: .error(ZcashError.synchronizerNotPrepared)
                ),
                syncProgressState: .initial,
                transactionListState: .initial,
                walletConfig: .initial
            )
        ) {
            HomeReducer()
        }
    }
}
