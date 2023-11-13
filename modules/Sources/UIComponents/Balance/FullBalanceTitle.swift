//
//  FullBalanceTitle.swift
//
//
//  Created by Lukáš Korba on 03.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit

public struct FullBalanceTitle: View {
    let primary: String
    let secondary: String
    let fontName: String
    let primaryFontSize: CGFloat
    let secondaryFontSize: CGFloat

    public init(
        primary: String,
        secondary: String,
        fontName: String,
        primaryFontSize: CGFloat,
        secondaryFontSize: CGFloat
    ) {
        self.primary = primary
        self.secondary = secondary
        self.fontName = fontName
        self.primaryFontSize = primaryFontSize
        self.secondaryFontSize = secondaryFontSize
    }
    
    public var body: some View {
        HStack {
            Text(primary)
                .font(.custom(fontName, size: primaryFontSize))
            + Text(secondary)
                .font(.custom(fontName, size: secondaryFontSize))
        }
    }
}

#Preview {
    VStack {
        FullBalanceTitle(
            primary: "0.001",
            secondary: "35466",
            fontName: FontFamily.Inter.regular.name,
            primaryFontSize: 13,
            secondaryFontSize: 9
        )
    }
}
