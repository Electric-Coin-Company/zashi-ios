//
//  SwiftUIView.swift
//  
//
//  Created by Lukáš Korba on 10.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit

public struct AvailableBalanceView: View {
    let balance: Zatoshi
    let tokenName: String
    let showIndicator: Bool
    let underlined: Bool
    
    public init(
        balance: Zatoshi,
        tokenName: String,
        showIndicator: Bool = false,
        underlined: Bool = true
    ) {
        self.balance = balance
        self.tokenName = tokenName
        self.showIndicator = showIndicator
        self.underlined = underlined
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            if underlined {
                Text(L10n.Balance.availableTitle)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .underline()
            } else {
                Text(L10n.Balance.availableTitle)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
            }
            
            if showIndicator {
                ProgressView()
                    .scaleEffect(0.9)
                    .padding(.horizontal, 3)
            } else {
                ZatoshiRepresentationView(
                    balance: balance,
                    fontName: FontFamily.Inter.bold.name,
                    mostSignificantFontSize: 14,
                    leastSignificantFontSize: 7,
                    format: .expanded
                )
            }
            
            Text(tokenName)
                .font(.custom(FontFamily.Inter.bold.name, size: 14))
        }
    }
}

#Preview {
    AvailableBalanceView(balance: Zatoshi(25_793_456), tokenName: "TAZ", showIndicator: true)
}
