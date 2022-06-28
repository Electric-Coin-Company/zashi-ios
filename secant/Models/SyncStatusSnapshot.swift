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
        case .downloading(let progress):
            return SyncStatusSnapshot(state, "downloading - \(String(format: "%d%%", Int(progress.progress * 100.0)))", progress.progress)
            
        case .enhancing(let enhanceProgress):
            return SyncStatusSnapshot(state, "Enhancing tx \(enhanceProgress.enhancedTransactions) of \(enhanceProgress.totalTransactions)")
            
        case .fetching:
            return SyncStatusSnapshot(state, "fetching UTXOs")
            
        case .scanning(let progress):
            return SyncStatusSnapshot(state, "scanning - \(String(format: "%d%%", Int(progress.progress * 100.0)))", progress.progress)
            
        case .disconnected:
            return SyncStatusSnapshot(state, "disconnected 💔")
            
        case .stopped:
            return SyncStatusSnapshot(state, "Stopped 🚫")
            
        case .synced:
            return SyncStatusSnapshot(state, "Up-To-Date")
            
        case .unprepared:
            return SyncStatusSnapshot(state, "Unprepared 😅")
            
        case .validating:
            return SyncStatusSnapshot(state, "Validating")
            
        case .error(let err):
            return SyncStatusSnapshot(state, "Error: \(err.localizedDescription)")
        }
    }
}

extension SyncStatusSnapshot {
    static let `default` = SyncStatusSnapshot()
}
