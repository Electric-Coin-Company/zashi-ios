//
//  SyncStatusSnapshot.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 07.07.2022.
//

import Foundation
import ZcashLightClientKit

struct SyncStatusSnapshot: Equatable {
    let message: String
    let syncStatus: SyncStatus
    
    init(_ syncStatus: SyncStatus = .unprepared, _ message: String = "") {
        self.message = message
        self.syncStatus = syncStatus
    }
    
    static func snapshotFor(state: SyncStatus) -> SyncStatusSnapshot {
        switch state {
        case .enhancing:
            return SyncStatusSnapshot(state, L10n.Sync.Message.enhancing)
            
        case .fetching:
            return SyncStatusSnapshot(state, L10n.Sync.Message.fetchingUTXO)
            
        case .disconnected:
            return SyncStatusSnapshot(state, L10n.Sync.Message.disconnected)
            
        case .stopped:
            return SyncStatusSnapshot(state, L10n.Sync.Message.stopped)
            
        case .synced:
            return SyncStatusSnapshot(state, L10n.Sync.Message.uptodate)
            
        case .unprepared:
            return SyncStatusSnapshot(state, L10n.Sync.Message.unprepared)
            
        case .error(let err):
            return SyncStatusSnapshot(state, L10n.Sync.Message.error(err.localizedDescription))

        case .syncing(let progress):
            return SyncStatusSnapshot(state, L10n.Sync.Message.sync(String(format: "%0.1f", progress.progress * 100)))
        }
    }
}

extension SyncStatusSnapshot {
    static let `default` = SyncStatusSnapshot()
}
