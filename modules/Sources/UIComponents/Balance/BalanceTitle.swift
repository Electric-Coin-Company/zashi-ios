//
//  BalanceTitle.swift
//
//
//  Created by Lukáš Korba on 19.10.2023.
//

import SwiftUI
import Generated
import ZcashLightClientKit

public struct BalanceTitle: View {
    let balance: Zatoshi
    
    public init(balance: Zatoshi) {
        self.balance = balance
    }
    
    public var body: some View {
        HStack {
            Text(balance.decimalString(formatter: NumberFormatter.zashiBalanceFormatter))
                .font(
                    .custom(FontFamily.Archivo.semiBold.name, size: 36)
                )
                .foregroundColor(Asset.Colors.primary.color)
            
            
            Circle()
                .frame(width: 25, height: 25)
                .foregroundColor(Asset.Colors.tabsUnderline.color)
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
        BalanceTitle(balance: Zatoshi(1_4050_000))

        BalanceTitle(balance: Zatoshi(1_4364_000))
        
        BalanceTitle(balance: Zatoshi(1_000_000))

        BalanceTitle(balance: Zatoshi(0))
    }
}
