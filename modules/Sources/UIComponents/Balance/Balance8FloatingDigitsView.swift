//
//  Balance8FloatingDigitsView.swift
//
//
//  Created by Lukáš Korba on 03.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit
import Utils

public struct Balance8FloatingDigitsView: View {
    let balanceSplit: BalanceZashiSplit
    let fontName: String
    let mainFontSize: CGFloat
    let restFontSize: CGFloat

    public init(
        balance: Zatoshi,
        fontName: String,
        mainFontSize: CGFloat,
        restFontSize: CGFloat,
        prefixSymbol: BalanceZashiSplit.PrefixSymbol = .none
    ) {
        self.balanceSplit = BalanceZashiSplit(balance: balance, prefixSymbol: prefixSymbol)
        self.fontName = fontName
        self.mainFontSize = mainFontSize
        self.restFontSize = restFontSize
    }
    
    public var body: some View {
        HStack {
            Text(balanceSplit.main)
                .font(.custom(fontName, size: mainFontSize))
            + Text(balanceSplit.rest)
                .font(.custom(fontName, size: restFontSize))
        }
    }
}

#Preview {
    let mainSize: CGFloat = 30
    let restSize: CGFloat = 9
    
    return VStack(spacing: 30) {
        Balance8FloatingDigitsView(
            balance: Zatoshi(25_793_456),
            fontName: FontFamily.Inter.regular.name,
            mainFontSize: mainSize,
            restFontSize: restSize
        )
        
        Balance8FloatingDigitsView(
            balance: Zatoshi(25_793_456),
            fontName: FontFamily.Inter.regular.name,
            mainFontSize: mainSize,
            restFontSize: restSize,
            prefixSymbol: .plus
        )
        
        Balance8FloatingDigitsView(
            balance: Zatoshi(25_793_456),
            fontName: FontFamily.Inter.regular.name,
            mainFontSize: mainSize,
            restFontSize: restSize,
            prefixSymbol: .minus
        )
    }
}
