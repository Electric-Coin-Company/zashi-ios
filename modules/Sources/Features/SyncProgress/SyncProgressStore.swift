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

public typealias SyncProgressStore = Store<SyncProgressReducer.State, SyncProgressReducer.Action>

public struct SyncProgressReducer: Reducer {
    private let CancelId = UUID()

    public struct State: Equatable { 
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
            lastKnownSyncPercentage: Float,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            syncStatusMessage: String = ""
        ) {
            self.lastKnownSyncPercentage = lastKnownSyncPercentage
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.syncStatusMessage = syncStatusMessage
        }
    }
    
    public enum Action: Equatable {
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

            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)
                if snapshot.syncStatus != state.synchronizerStatusSnapshot.syncStatus {
                    state.synchronizerStatusSnapshot = snapshot

                    if case .syncing(let progress) = snapshot.syncStatus {
                        state.lastKnownSyncPercentage = progress
                    }

                    switch snapshot.syncStatus {
                    case .syncing:
                        state.syncStatusMessage = L10n.Balances.syncing
                    case .upToDate, .stopped:
                        state.lastKnownSyncPercentage = 1
                        state.syncStatusMessage = L10n.Balances.synced
                    case .error, .unprepared:
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

// MARK: - Store

extension SyncProgressStore {
    public static var initial = SyncProgressStore(
        initialState: .initial
    ) {
        SyncProgressReducer()
    }
}

// MARK: - Placeholders

extension SyncProgressReducer.State {
    public static let initial = SyncProgressReducer.State(
        lastKnownSyncPercentage: 0,
        synchronizerStatusSnapshot: .initial
    )
}
