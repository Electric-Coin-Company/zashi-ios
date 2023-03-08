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
            VStack {
                HStack {
                    Spacer()
                    Text(L10n.BalanceBreakdown.blockId(viewStore.latestBlock))
                        .foregroundColor(Asset.Colors.Mfp.fontLight.color)
                }
                
                .padding(.horizontal, 50)
                VStack(alignment: .leading, spacing: 10) {
                    balanceView(
                        title: L10n.BalanceBreakdown.shieldedZec(TargetConstants.tokenName),
                        viewStore.shieldedBalance.data.total,
                        titleColor: Asset.Colors.Mfp.fontDark.color
                    )
                    balanceView(title: L10n.BalanceBreakdown.transparentBalance, viewStore.transparentBalance.data.total)
                    balanceView(title: L10n.BalanceBreakdown.totalBalance, viewStore.totalBalance)

                    shieldButton(viewStore)
                }
                .padding(30)
                .background(Asset.Colors.Mfp.background.color)
                .onAppear { viewStore.send(.onAppear) }
                
                HStack {
                    Spacer()
                    Text(
                        L10n.BalanceBreakdown.autoShieldingThreshold(
                            viewStore.autoShieldingThreshold.decimalString(),
                            TargetConstants.tokenName
                        )
                    )
                    .foregroundColor(Asset.Colors.Mfp.fontLight.color)
                }
                .padding(.horizontal, 50)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .applySemiTransparentScreenBackground()
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                viewStore.send(.onDisappear)
            }
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
        }
        .background(ClearBackgroundView())
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
        .padding(.top, 30)
        .disabled(viewStore.shieldingFunds)
    }
}

struct BalanceBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        BalanceBreakdownView(store: .placeholder)
            .preferredColorScheme(.light)
    }
}
