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
import WalletBalances

public typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
public typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

public struct HomeReducer: Reducer {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var canRequestReview = false
        public var isRestoringWallet = false
        public var migratingDatabase = true
        public var scanState: Scan.State
        public var syncProgressState: SyncProgressReducer.State
        public var walletConfig: WalletConfig
        public var transactionListState: TransactionListReducer.State
        public var walletBalancesState: WalletBalances.State

        public init(
            canRequestReview: Bool = false,
            isRestoringWallet: Bool = false,
            migratingDatabase: Bool = true,
            scanState: Scan.State,
            syncProgressState: SyncProgressReducer.State,
            transactionListState: TransactionListReducer.State,
            walletBalancesState: WalletBalances.State,
            walletConfig: WalletConfig
        ) {
            self.canRequestReview = canRequestReview
            self.isRestoringWallet = isRestoringWallet
            self.migratingDatabase = migratingDatabase
            self.scanState = scanState
            self.syncProgressState = syncProgressState
            self.transactionListState = transactionListState
            self.walletConfig = walletConfig
            self.walletBalancesState = walletBalancesState
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
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
        case walletBalances(WalletBalances.Action)
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

        Scope(state: \.walletBalancesState, action: /Action.walletBalances) {
            WalletBalances()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.walletBalancesState.migratingDatabase = state.migratingDatabase
                state.migratingDatabase = false
                return .publisher {
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
                
            case .syncFailed:
                return .none

            case .walletBalances:
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
            syncProgressState: .initial,
            transactionListState: .initial,
            walletBalancesState: .initial,
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
                syncProgressState: .initial,
                transactionListState: .initial,
                walletBalancesState: .initial,
                walletConfig: .initial
            )
        ) {
            HomeReducer()
        }
    }
}
