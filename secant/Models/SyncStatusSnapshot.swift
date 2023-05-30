//
//  SyncStatusSnapshot.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 07.07.2022.
//

import Foundation
import ZcashLightClientKit
import Generated

struct SyncStatusSnapshot: Equatable {
    let message: String
    let syncStatus: SyncStatus
    
    init(_ syncStatus: SyncStatus = .unprepared, _ message: String = "") {
        self.message = message
        self.syncStatus = syncStatus
    }
    
    static func snapshotFor(state: SyncStatus) -> SyncStatusSnapshot {
        switch state {
        case .upToDate:
            return SyncStatusSnapshot(state, L10n.Sync.Message.uptodate)
            
        case .unprepared:
            return SyncStatusSnapshot(state, L10n.Sync.Message.unprepared)
            
        case .error(let error):
            return SyncStatusSnapshot(state, L10n.Sync.Message.error(error.toZcashError().message))

        case .syncing(let progress):
            return SyncStatusSnapshot(state, L10n.Sync.Message.sync(String(format: "%0.1f", progress * 100)))
        }
    }
}

extension SyncStatusSnapshot {
    static let `default` = SyncStatusSnapshot()
}
