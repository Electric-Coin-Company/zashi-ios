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

// MARK: - Model

struct WalletEvent: Equatable, Identifiable {
    enum WalletEventState: Equatable {
        case send(TransactionState)
        case pending(TransactionState)
        case received(TransactionState)
        case failed(TransactionState)
        case shielded(Zatoshi)
        case walletImport(BlockHeight)
    }
    
    let id: String
    let state: WalletEventState
    var timestamp: TimeInterval
}

// MARK: - Rows

extension WalletEvent {
    @ViewBuilder func rowView(_ viewStore: WalletEventsFlowViewStore) -> some View {
        switch state {
        case .send(let transaction),
            .pending(let transaction),
            .received(let transaction),
            .failed(let transaction):
            TransactionRowView(transaction: transaction)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text("shielded wallet event \(zatoshi.decimalString())")
        case .walletImport:
            // TODO: [#391] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/391
            Text("wallet import wallet event")
        }
    }
}

// MARK: - Details

extension WalletEvent {
    @ViewBuilder func detailView(_ store: WalletEventsFlowStore) -> some View {
        switch state {
        case .send(let transaction),
            .pending(let transaction),
            .received(let transaction),
            .failed(let transaction):
            TransactionDetailView(transaction: transaction, store: store)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text("shielded \(zatoshi.decimalString()) detail")
        case .walletImport:
            // TODO: [#391] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/391
            Text("wallet import wallet event")
        }
    }
}

// MARK: - Placeholders

private extension WalletEvent {
    static func randomWalletEventState() -> WalletEvent.WalletEventState {
        switch Int.random(in: 0..<6) {
        case 1: return .received(.statePlaceholder(.received))
        case 2: return .failed(.statePlaceholder(.failed))
        case 3: return .shielded(Zatoshi(234_000_000))
        case 4: return .walletImport(BlockHeight(1_629_724))
        case 5: return .pending(.statePlaceholder(.pending))
        default: return .send(.placeholder)
        }
    }
}

extension IdentifiedArrayOf where Element == WalletEvent {
    static var placeholder: IdentifiedArrayOf<WalletEvent> {
        return .init(
            uniqueElements: (0..<30).map {
                WalletEvent(
                    id: String($0),
                    state: WalletEvent.randomWalletEventState(),
                    timestamp: 1234567
                )
            }
        )
    }
}
