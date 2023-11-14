import UIKit
import SwiftUI
import AVFoundation
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import DiskSpaceChecker
import Utils
import Models
import Generated
import ReviewRequest
import TransactionList
import Scan

public typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
public typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

public struct HomeReducer: Reducer {
    private enum CancelId { case timer }
    let networkType: NetworkType

    public struct State: Equatable {
        public enum Destination: Equatable {
            case notEnoughFreeDiskSpace
        }

        @PresentationState public var alert: AlertState<Action>?
        public var destination: Destination?
        public var canRequestReview = false
        public var requiredTransactionConfirmations = 0
        public var scanState: ScanReducer.State
        public var shieldedBalance: Balance
        public var synchronizerStatusSnapshot: SyncStatusSnapshot
        public var walletConfig: WalletConfig
        public var transactionListState: TransactionListReducer.State
        public var migratingDatabase = true
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
        public var zecPrice = Decimal(140.0)

        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.verified.decimalValue.decimalValue * zecPrice)
        }

        public var isSendButtonDisabled: Bool {
            shieldedBalance.data.verified.amount == 0
        }
        
        public init(
            destination: Destination? = nil,
            canRequestReview: Bool = false,
            requiredTransactionConfirmations: Int = 0,
            scanState: ScanReducer.State,
            shieldedBalance: Balance,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            walletConfig: WalletConfig,
            transactionListState: TransactionListReducer.State,
            zecPrice: Decimal = Decimal(140.0)
        ) {
            self.destination = destination
            self.canRequestReview = canRequestReview
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.walletConfig = walletConfig
            self.transactionListState = transactionListState
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
        case retrySync
        case reviewRequestFinished
        case showSynchronizerErrorAlert(ZcashError)
        case synchronizerStateChanged(SynchronizerState)
        case syncFailed(ZcashError)
        case updateDestination(HomeReducer.State.Destination?)
        case updateTransactionList([TransactionState])
        case transactionList(TransactionListReducer.Action)
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.transactionListState, action: /Action.transactionList) {
            TransactionListReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations

                if diskSpaceChecker.hasEnoughFreeSpaceForSync() {
                    // TODO: [#904] side effects refactor, https://github.com/Electric-Coin-Company/zashi-ios/issues/904
                    return .none
//                    let syncEffect = sdkSynchronizer.stateStream()
//                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
//                        .map(HomeReducer.Action.synchronizerStateChanged)
//                        .eraseToEffect()
//                        .cancellable(id: CancelId.timer, cancelInFlight: true)
//                    return .merge(
//                        Effect.send(.updateDestination(nil)),
//                        syncEffect
//                    )
                } else {
                    return Effect.send(.updateDestination(.notEnoughFreeDiskSpace))
                }
                
            case .onDisappear:
                return .none
                return .cancel(id: CancelId.timer)
                
            case .resolveReviewRequest:
                // TODO: [#904] side effects refactor, https://github.com/Electric-Coin-Company/zashi-ios/issues/904
//                if reviewRequest.canRequestReview() {
//                    state.canRequestReview = true
//                    return .fireAndForget { reviewRequest.reviewRequested() }
//                }
                return .none
                
            case .reviewRequestFinished:
                state.canRequestReview = false
                return .none
                                
            case .updateTransactionList:
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.syncStatus)

                guard snapshot.syncStatus != state.synchronizerStatusSnapshot.syncStatus else {
                    return .none
                }

                if snapshot.syncStatus != .unprepared {
                    state.migratingDatabase = false
                }

                state.synchronizerStatusSnapshot = snapshot
                state.shieldedBalance = latestState.shieldedBalance.redacted

                switch snapshot.syncStatus {
                case .error(let error):
                    return Effect.send(.showSynchronizerErrorAlert(error.toZcashError()))

                case .upToDate:
                    // TODO: [#904] side effects refactor, https://github.com/Electric-Coin-Company/zashi-ios/issues/904
//                    return .fireAndForget { reviewRequest.syncFinished() }
                    return .none

                default:
                    return .none
                }

            case .foundTransactions:
                // TODO: [#904] side effects refactor, https://github.com/Electric-Coin-Company/zashi-ios/issues/904
//                return .fireAndForget { reviewRequest.foundTransactions() }
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none
                
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

// MARK: - ViewStore

extension HomeViewStore {
    func bindingForDestination(_ destination: HomeReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}

// MARK: Placeholders

extension HomeReducer.State {
    public static var initial: Self {
        .init(
            scanState: .initial,
            shieldedBalance: Balance.zero,
            synchronizerStatusSnapshot: .initial,
            walletConfig: .initial,
            transactionListState: .initial
        )
    }
}

extension HomeStore {
    public static var placeholder: HomeStore {
        HomeStore(
            initialState: .initial
        ) {
            HomeReducer(networkType: .testnet)
        }
    }

    public static var error: HomeStore {
        HomeStore(
            initialState: .init(
                scanState: .initial,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .snapshotFor(
                    state: .error(ZcashError.synchronizerNotPrepared)
                ),
                walletConfig: .initial,
                transactionListState: .initial
            )
        ) {
            HomeReducer(networkType: .testnet)
        }
    }
}
