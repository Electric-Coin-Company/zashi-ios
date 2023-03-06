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
                    Text("balanceBreakdown.blockId".localized("\(viewStore.latestBlock)"))
                        .foregroundColor(Asset.Colors.Mfp.fontLight.color)
                }
                
                .padding(.horizontal, 50)
                VStack(alignment: .leading, spacing: 10) {
                    balanceView(
                        title: "balanceBreakdown.ShieldedZec",
                        viewStore.shieldedBalance.data.total,
                        titleColor: Asset.Colors.Mfp.fontDark.color
                    )
                    balanceView(title: "balanceBreakdown.transparentBalance", viewStore.transparentBalance.data.total)
                    balanceView(title: "balanceBreakdown.totalBalance", viewStore.totalBalance)
                }
                .padding(30)
                .background(Asset.Colors.Mfp.background.color)
                .onAppear { viewStore.send(.onAppear) }
                
                HStack {
                    Spacer()
                    Text(
                        "balanceBreakdown.autoShieldingThreshold".localized(
                            "\(viewStore.autoShieldingThreshold.decimalString())"
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
                "balance".localized(
                    "\(balance.decimalString(formatter: NumberFormatter.zcashNumberFormatter8FractionDigits))"
                )
            )
            .font(.system(size: 32))
            .fontWeight(.bold)
            .foregroundColor(Asset.Colors.Mfp.fontDark.color)
        }
    }
}

struct BalanceBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        BalanceBreakdownView(store: .placeholder)
            .preferredColorScheme(.light)
    }
}
