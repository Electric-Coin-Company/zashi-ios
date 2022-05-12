//
//  SDKSynchronizer+SyncStatus.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import ZcashLightClientKit

extension SDKSynchronizer {
    static func textFor(state: SyncStatus) -> String {
        switch state {
        case .downloading(let progress):
            return "Downloading \(progress.progressHeight)/\(progress.targetHeight)"

        case .enhancing(let enhanceProgress):
            return "Enhancing tx \(enhanceProgress.enhancedTransactions) of \(enhanceProgress.totalTransactions)"

        case .fetching:
            return "fetching UTXOs"

        case .scanning(let scanProgress):
            return "Scanning: \(scanProgress.progressHeight)/\(scanProgress.targetHeight)"

        case .disconnected:
            return "disconnected 💔"

        case .stopped:
            return "Stopped 🚫"

        case .synced:
            return "Synced 😎"

        case .unprepared:
            return "Unprepared 😅"

        case .validating:
            return "Validating"

        case .error(let err):
            return "Error: \(err.localizedDescription)"
        }
    }
}
