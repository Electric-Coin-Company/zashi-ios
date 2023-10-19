//
//  WalletEvent+View.swift
//  secant
//
//  Created by Lukáš Korba on 30.05.2023.
//

import ComposableArchitecture
import Models
import Generated
import SwiftUI
import ZcashLightClientKit

// MARK: - Rows

extension WalletEvent {
    @ViewBuilder public func rowView(_ viewStore: WalletEventsFlowViewStore, tokenName: String) -> some View {
        switch state {
        case .transaction(let transaction):
            TransactionRowView(transaction: transaction, tokenName: tokenName)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text(L10n.WalletEvent.Row.shielded(zatoshi.decimalZashiFormatted()))
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
    @ViewBuilder public func detailView(_ store: WalletEventsFlowStore, tokenName: String) -> some View {
        switch state {
        case .transaction(let transaction):
            TransactionDetailView(store: store, transaction: transaction, tokenName: tokenName)
        case .shielded(let zatoshi):
            // TODO: [#390] implement design once shielding is supported
            // https://github.com/zcash/secant-ios-wallet/issues/390
            Text(L10n.WalletEvent.Detail.shielded(zatoshi.decimalZashiFormatted()))
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
        switch Int.random(in: 0..<3) {
        case 1: return .shielded(Zatoshi(234_000_000))
        case 2: return .walletImport(BlockHeight(1_629_724))
        default: return .transaction(.placeholder)
        }
    }
    
    static func mockedWalletEventState(atIndex: Int) -> WalletEvent.WalletEventState {
        switch atIndex % 5 {
        case 0: return .transaction(.statePlaceholder(.received))
        case 1: return .transaction(.statePlaceholder(.failed))
        case 2: return .transaction(.statePlaceholder(.sending))
        case 3: return .transaction(.statePlaceholder(.receiving))
        case 4: return .transaction(.placeholder)
        default: return .transaction(.placeholder)
        }
    }
}

extension IdentifiedArrayOf where Element == WalletEvent {
    public static var placeholder: IdentifiedArrayOf<WalletEvent> {
        .init(
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
