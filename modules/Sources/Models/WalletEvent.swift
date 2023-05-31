//
//  WalletEvent.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 20.06.2022.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils

// MARK: - Model

public struct WalletEvent: Equatable, Identifiable, Redactable {
    public enum WalletEventState: Equatable {
        case transaction(TransactionState)
        case shielded(Zatoshi)
        case walletImport(BlockHeight)
    }
    
    public let id: String
    public let state: WalletEventState
    public var timestamp: TimeInterval?
    
    public init(id: String, state: WalletEventState, timestamp: TimeInterval? = nil) {
        self.id = id
        self.state = state
        self.timestamp = timestamp
    }
}
