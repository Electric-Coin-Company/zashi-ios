//
//  BalanceBreakdownView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Generated
import UIComponents

public struct BalanceBreakdownView: View {
    let store: BalanceBreakdownStore
    let tokenName: String
    
    public init(store: BalanceBreakdownStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(viewStore.synchronizerStatusSnapshot.message)
                        Text(L10n.BalanceBreakdown.blockId(viewStore.latestBlock))
                    }
                    .foregroundColor(Asset.Colors.primary.color)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 20)

                balanceView(
                    title: L10n.BalanceBreakdown.shieldedZec(tokenName),
                    viewStore.shieldedBalance.data.verified,
                    titleColor: Asset.Colors.primary.color
                )
                balanceView(title: L10n.BalanceBreakdown.transparentBalance, viewStore.transparentBalance.data.verified)
                balanceView(title: L10n.BalanceBreakdown.totalSpendableBalance, viewStore.totalBalance)
                
                shieldButton(viewStore)
                
                HStack {
                    Spacer()
                    Text(
                        L10n.BalanceBreakdown.autoShieldingThreshold(
                            viewStore.autoShieldingThreshold.decimalZashiFormatted(),
                            tokenName
                        )
                    )
                    .foregroundColor(Asset.Colors.primary.color)
                }
                .padding(.horizontal, 50)
                
                Spacer()
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
        .applyScreenBackground()
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
    }
}

extension BalanceBreakdownView {
    func balanceView(title: String, _ balance: Zatoshi, titleColor: Color = Asset.Colors.primary.color) -> some View {
        VStack(alignment: .leading) {
            Text("\(title)")
                .foregroundColor(titleColor)
            
            BalanceTitle(balance: balance)
        }
        .padding(.horizontal, 50)
    }

    func shieldButton(_ viewStore: BalanceBreakdownViewStore) -> some View {
        Button(
            action: { viewStore.send(.shieldFunds) },
            label: {
                if viewStore.shieldingFunds {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Asset.Colors.primary.color))
                        Text(L10n.BalanceBreakdown.shieldingFunds.uppercased())
                    }
                } else {
                    Text(L10n.BalanceBreakdown.shieldFunds)
                }
            }
        )
        .zcashStyle()
        .padding(.horizontal, 70)
        .padding(.vertical, 20)
        .disabled(!viewStore.isShieldableBalanceAvailable || viewStore.shieldingFunds)
    }
}

struct BalanceBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        BalanceBreakdownView(store: .placeholder, tokenName: "ZEC")
            .preferredColorScheme(.light)
    }
}
