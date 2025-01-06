//
//  TransactionFeeView.swift
//
//
//  Created by Lukáš Korba on 04.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit
import UIComponents

public struct TransactionFeeView: View {
    @Environment(\.colorScheme) private var colorScheme
    let fee: Zatoshi

    public init(fee: Zatoshi) {
        self.fee = fee
    }
    
    public var body: some View {
        HStack {
            Text(L10n.TransactionList.transactionFee)
                .font(.custom(FontFamily.Inter.regular.name, size: 13))
                .foregroundColor(Asset.Colors.shade47.color)
            
            Spacer()
            
            ZatoshiRepresentationView(
                balance: fee,
                fontName: FontFamily.Inter.medium.name,
                mostSignificantFontSize: 13,
                isFee: fee.amount == 0,
                leastSignificantFontSize: 7,
                format: .expanded
            )
            .foregroundColor(
                fee.amount == 0
                ? Asset.Colors.shade47.color
                : Design.Utility.ErrorRed._600.color(colorScheme)
            )
            .fixedSize()
        }
    }
}

#Preview {
    TransactionFeeView(fee: Zatoshi(10_000))
}
