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
    let progress: Float
    let syncStatus: SyncStatus
    
    init(_ syncStatus: SyncStatus = .unprepared, _ message: String = "", _ progress: Float = 0) {
        self.message = message
        self.progress = progress
        self.syncStatus = syncStatus
    }
    
    static func snapshotFor(state: SyncStatus) -> SyncStatusSnapshot {
        switch state {
        case .enhancing(let enhanceProgress):
            return SyncStatusSnapshot(state, "Enhancing tx \(enhanceProgress.enhancedTransactions) of \(enhanceProgress.totalTransactions)")
            
        case .fetching:
            return SyncStatusSnapshot(state, "fetching UTXOs")
            
        case .disconnected:
            return SyncStatusSnapshot(state, "disconnected 💔")
            
        case .stopped:
            return SyncStatusSnapshot(state, "Stopped 🚫")
            
        case .synced:
            return SyncStatusSnapshot(state, "Up-To-Date")
            
        case .unprepared:
            return SyncStatusSnapshot(state, "Unprepared 😅")
            
        case .error(let err):
            return SyncStatusSnapshot(state, "Error: \(err.localizedDescription)")
        
        case .syncing(let progress):
            return SyncStatusSnapshot(state, "Syncing \(progress)")
        }
    }
}

extension SyncStatusSnapshot {
    static let `default` = SyncStatusSnapshot()
}
