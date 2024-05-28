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

@Reducer
public struct Home {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var canRequestReview = false
        public var migratingDatabase = true
        public var scanState: Scan.State
        public var syncProgressState: SyncProgress.State
        public var walletConfig: WalletConfig
        public var transactionListState: TransactionList.State
        public var walletBalancesState: WalletBalances.State

        public init(
            canRequestReview: Bool = false,
            migratingDatabase: Bool = true,
            scanState: Scan.State,
            syncProgressState: SyncProgress.State,
            transactionListState: TransactionList.State,
            walletBalancesState: WalletBalances.State,
            walletConfig: WalletConfig
        ) {
            self.canRequestReview = canRequestReview
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
        case connectivityStatusChanged(ConnectionState)
        case foundTransactions
        case onAppear
        case onDisappear
        case resolveReviewRequest
        case retrySync
        case reviewRequestFinished
        case showSynchronizerErrorAlert(ZcashError)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case syncFailed(ZcashError)
        case syncProgress(SyncProgress.Action)
        case updateTransactionList([TransactionState])
        case transactionList(TransactionList.Action)
        case walletBalances(WalletBalances.Action)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.transactionListState, action: /Action.transactionList) {
            TransactionList()
        }

        Scope(state: \.syncProgressState, action: /Action.syncProgress) {
            SyncProgress()
        }

        Scope(state: \.walletBalancesState, action: /Action.walletBalances) {
            WalletBalances()
        }

        Reduce { state, action in
            switch action {
            case .connectivityStatusChanged(let newValue):
                return .none
                
            case .onAppear:
                state.walletBalancesState.migratingDatabase = state.migratingDatabase
                state.migratingDatabase = false
                return .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions = $0 {
                                    return HomeReducer.Action.foundTransactions
                                } else if case SynchronizerEvent.connectionStateChanged(let newState) = $0 {
                                    return HomeReducer.Action.connectivityStatusChanged(newState)
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
