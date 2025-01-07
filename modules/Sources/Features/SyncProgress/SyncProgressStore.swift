//
//  SyncProgressStore.swift
//
//
//  Created by Lukáš Korba on 21.12.2023.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import Models
import SDKSynchronizer
import Utils

@Reducer
public struct SyncProgress {
    private let CancelId = UUID()

    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var lastKnownErrorMessage: String?
        public var lastKnownSyncPercentage: Float = 0
        public var synchronizerStatusSnapshot: SyncStatusSnapshot
        public var syncStatusMessage = ""

        public var isSyncing: Bool {
            synchronizerStatusSnapshot.syncStatus.isSyncing
        }
        
        public var syncingPercentage: Float {
            if case .syncing(let progress) = synchronizerStatusSnapshot.syncStatus {
                // Report at most 99.9% until the wallet is fully ready.
                return progress * 0.999
            }
            
            return lastKnownSyncPercentage
        }
        
        public init(
            lastKnownErrorMessage: String? = nil,
            lastKnownSyncPercentage: Float,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            syncStatusMessage: String = ""
        ) {
            self.lastKnownErrorMessage = lastKnownErrorMessage
            self.lastKnownSyncPercentage = lastKnownSyncPercentage
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.syncStatusMessage = syncStatusMessage
        }
    }
    
    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case errorMessageTapped
        case onAppear
        case onDisappear
        case synchronizerStateChanged(RedactableSynchronizerState)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map { $0.redacted }
                        .map(Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelId, cancelInFlight: true)

            case .onDisappear:
                return .cancel(id: CancelId)

            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none
                
            case .errorMessageTapped:
                if let errorMessage = state.lastKnownErrorMessage {
                    state.alert = AlertState.errorMessage(errorMessage)
                }
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)
                if snapshot.syncStatus != state.synchronizerStatusSnapshot.syncStatus {
                    state.synchronizerStatusSnapshot = snapshot

                    if case .syncing(let progress) = snapshot.syncStatus {
                        state.lastKnownSyncPercentage = progress
                    }

                    state.lastKnownErrorMessage = nil

                    switch snapshot.syncStatus {
                    case .syncing:
                        state.syncStatusMessage = L10n.Balances.syncing
                    case .upToDate, .stopped:
                        state.lastKnownSyncPercentage = 1
                        state.syncStatusMessage = L10n.Balances.synced
                    case .error, .unprepared:
                        state.lastKnownErrorMessage = snapshot.message
                        #if DEBUG
                        state.syncStatusMessage = snapshot.message
                        #else
                        state.syncStatusMessage = L10n.Balances.syncingError
                        #endif
                    }
                }

                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SyncProgress.Action {
    public static func errorMessage(_ message: String) -> AlertState {
        AlertState {
            TextState(L10n.Sync.Alert.title)
        } message: {
            TextState(message)
        }
    }
}
