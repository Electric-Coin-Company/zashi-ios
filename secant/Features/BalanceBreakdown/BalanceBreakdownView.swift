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
                    Text("Block: \(viewStore.latestBlock)")
                }
                
                .padding(.horizontal, 50)
                VStack(alignment: .leading, spacing: 10) {
                    balanceView(title: "SHIELDED ZEC (SPENDABLE)", viewStore.shieldedBalance.total, titleColor: Asset.Colors.Text.balanceText.color)
                    balanceView(title: "TRANSPARENT BALANCE", viewStore.transparentBalance.total)
                    balanceView(title: "TOTAL BALANCE", viewStore.totalBalance)
                }
                .padding(30)
                .background(Asset.Colors.ScreenBackground.modalDialog.color)
                .cornerRadius(8)
                .onAppear { viewStore.send(.onAppear) }
                
                HStack {
                    Spacer()
                    Text("Auto Shielding Threshold: \(viewStore.autoShieldingThreshold.decimalString()) ZEC")
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
    func balanceView(title: String, _ balance: Zatoshi, titleColor: Color = .white) -> some View {
        VStack(alignment: .leading) {
            Text("\(title)")
                .foregroundColor(titleColor)
            Text("$\(balance.decimalString(formatter: NumberFormatter.zcashNumberFormatter8FractionDigits))")
                .font(.custom(FontFamily.Zboto.regular.name, size: 40))
                .foregroundColor(Color.white)
        }
    }
}

struct BalanceBreakdown_Previews: PreviewProvider {
    static var previews: some View {
        BalanceBreakdownView(store: .placeholder)
            .preferredColorScheme(.dark)
    }
}
