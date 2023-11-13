//
//  TransactionFeeView.swift
//
//
//  Created by Lukáš Korba on 04.11.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit

public struct TransactionFeeView: View {
    let fee: Zatoshi
    
    public init(fee: Zatoshi) {
        self.fee = fee
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.TransactionList.transactionFee)
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                    .foregroundColor(Asset.Colors.shade47.color)
                
                Text(fee.decimalString(formatter: NumberFormatter.zashiBalanceFormatter))
                    .font(.custom(FontFamily.Inter.bold.name, size: 13))
                    .foregroundColor(Asset.Colors.shade47.color)
            }
            
            Color.clear
        }
    }
}

#Preview {
    TransactionFeeView(fee: Zatoshi(10_000))
}
