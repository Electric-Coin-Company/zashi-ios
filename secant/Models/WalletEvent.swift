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

struct WalletEvent: Equatable, Identifiable, Redactable {
    enum WalletEventState: Equatable {
        case sent(TransactionState)
        case pending(TransactionState)
        case received(TransactionState)
        case failed(TransactionState)
        case shielded(Zatoshi)
        case walletImport(BlockHeight)
    }
    
    let id: String
    let state: WalletEventState
    var timestamp: TimeInterval?
}

// MARK: - Rows

extension WalletEvent {
    @ViewBuilder func rowView(_ viewStore: WalletEventsFlowViewStore) -> some View {
        switch state {
        case .sent(let transaction),
            .pending(let transaction),
            .received(let transaction),
            .failed(let transaction):
            TransactionRowView(transaction: transaction)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text(L10n.WalletEvent.Row.shielded(zatoshi.decimalString()))
                .padding(.leading, 30)
        case .walletImport:
            // TODO: [#391] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/391
            Text(L10n.WalletEvent.Row.import)
                .padding(.leading, 30)
        }
    }
}

// MARK: - Details

extension WalletEvent {
    @ViewBuilder func detailView(_ store: WalletEventsFlowStore) -> some View {
        switch state {
        case .sent(let transaction),
            .pending(let transaction),
            .received(let transaction),
            .failed(let transaction):
            TransactionDetailView(transaction: transaction, store: store)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text(L10n.WalletEvent.Detail.shielded(zatoshi.decimalString()))
        case .walletImport:
            // TODO: [#391] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/391
            Text(L10n.WalletEvent.Detail.import)
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
        default: return .sent(.placeholder)
        }
    }
    
    static func mockedWalletEventState(atIndex: Int) -> WalletEvent.WalletEventState {
        switch atIndex % 4 {
        case 0: return .received(.statePlaceholder(.received))
        case 1: return .failed(.statePlaceholder(.failed))
        case 2: return .pending(.statePlaceholder(.pending))
        case 3: return .sent(.placeholder)
        default: return .sent(.placeholder)
        }
    }
}

extension IdentifiedArrayOf where Element == WalletEvent {
    static var placeholder: IdentifiedArrayOf<WalletEvent> {
        return .init(
            uniqueElements: (0..<30).map {
                WalletEvent(
                    id: String($0),
                    state: WalletEvent.mockedWalletEventState(atIndex: $0),
                    timestamp: 1234567
                )
            }
        )
    }
}
