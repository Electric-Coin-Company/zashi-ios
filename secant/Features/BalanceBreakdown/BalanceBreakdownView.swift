//
//  BalanceBreakdownView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

struct BalanceBreakdownView: View {
    let store: BalanceBreakdownStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text(L10n.BalanceBreakdown.blockId(viewStore.latestBlock))
                        .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 20)

                balanceView(
                    title: L10n.BalanceBreakdown.shieldedZec(TargetConstants.tokenName),
                    viewStore.shieldedBalance.data.total,
                    titleColor: Asset.Colors.Mfp.fontDark.color
                )
                balanceView(title: L10n.BalanceBreakdown.transparentBalance, viewStore.transparentBalance.data.total)
                balanceView(title: L10n.BalanceBreakdown.totalBalance, viewStore.totalBalance)
                
                shieldButton(viewStore)
                
                HStack {
                    Spacer()
                    Text(
                        L10n.BalanceBreakdown.autoShieldingThreshold(
                            viewStore.autoShieldingThreshold.decimalString(),
                            TargetConstants.tokenName
                        )
                    )
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
                .padding(.horizontal, 50)
                
                Spacer()
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
        .applyScreenBackground()
    }
}

extension BalanceBreakdownView {
    func balanceView(title: String, _ balance: Zatoshi, titleColor: Color = Asset.Colors.Mfp.fontDark.color) -> some View {
        VStack(alignment: .leading) {
            Text("\(title)")
                .foregroundColor(titleColor)
            Text(
                L10n.balance(
                    balance.decimalString(formatter: NumberFormatter.zcashNumberFormatter8FractionDigits),
                    TargetConstants.tokenName
                )
            )
            .font(.system(size: 32))
            .fontWeight(.bold)
            .foregroundColor(Asset.Colors.Mfp.fontDark.color)
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
                            .progressViewStyle(CircularProgressViewStyle(tint: Asset.Colors.Text.activeButtonText.color))
                        Text(L10n.BalanceBreakdown.shieldingFunds)
                    }
                } else {
                    Text(L10n.BalanceBreakdown.shieldFunds)
                }
            }
        )
        .activeButtonStyle
        .padding(.horizontal, 50)
        .padding(.vertical, 20)
        .disable(when: !viewStore.isShieldableBalanceAvailable || viewStore.shieldingFunds, dimmingOpacity: 0.5)
    }
}

struct BalanceBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        BalanceBreakdownView(store: .placeholder)
            .preferredColorScheme(.light)
    }
}
