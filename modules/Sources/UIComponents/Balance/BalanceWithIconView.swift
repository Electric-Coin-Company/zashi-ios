//
//  BalanceWithIconView.swift
//
//
//  Created by Lukáš Korba on 19.10.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit

public struct BalanceWithIconView: View {
    let balance: Zatoshi
    let couldBeHidden: Bool
    
    public init(balance: Zatoshi, couldBeHidden: Bool = false) {
        self.balance = balance
        self.couldBeHidden = couldBeHidden
    }
    
    public var body: some View {
        HStack {
            ZatoshiRepresentationView(
                balance: balance,
                fontName: FontFamily.Inter.semiBold.name,
                mostSignificantFontSize: 42,
                leastSignificantFontSize: 10,
                format: .expanded,
                couldBeHidden: couldBeHidden
            )
            
            Circle()
                .frame(width: 25, height: 25)
                .foregroundColor(Design.Surfaces.brandBg.color)
                .overlay {
                    ZcashSymbol()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Asset.Colors.secondary.color)
                }
        }
    }
}

#Preview {
    VStack {
        BalanceWithIconView(balance: Zatoshi(25_793_456))
        
        BalanceWithIconView(balance: Zatoshi(1_4050_000))

        BalanceWithIconView(balance: Zatoshi(1_4364_000))
        
        BalanceWithIconView(balance: Zatoshi(1_000_000))

        BalanceWithIconView(balance: Zatoshi(98_000))

        BalanceWithIconView(balance: Zatoshi(0))
    }
}
