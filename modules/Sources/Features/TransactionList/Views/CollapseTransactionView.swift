//
//  CollapseTransactionView.swift
//  
//
//  Created by Lukáš Korba on 04.11.2023.
//

import SwiftUI
import Generated

public struct CollapseTransactionView: View {
    public var body: some View {
        HStack {
            Asset.Assets.upArrow.image
                .zImage(width: 10, height: 7, style: Design.Surfaces.brandBg)
                .scaleEffect(0.6)
                .zFont(.black, size: 10, style: Design.Surfaces.brandBg)
                .overlay {
                    Rectangle()
                        .stroke()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Asset.Colors.shade47.color)
                }
            
            Text(L10n.TransactionList.collapse)
                .font(.custom(FontFamily.Inter.italic.name, size: 13))
                .foregroundColor(Asset.Colors.shade47.color)
                .underline()
        }
    }
}

#Preview {
    CollapseTransactionView()
}
