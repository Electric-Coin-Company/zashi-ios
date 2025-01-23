//
//  NoTransactionPlaceholder.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-22-2025.
//

import SwiftUI
import Generated

public struct NoTransactionPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme

    public init() {
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Circle()
                .frame(width: 40, height: 40)
                .zForegroundColor(Design.Surfaces.bgSecondary)
                .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .frame(width: 86, height: 14)
                
                RoundedRectangle(cornerRadius: 7)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .frame(width: 64, height: 14)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 7)
                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                .frame(width: 32, height: 14)
        }
        .screenHorizontalPadding()
        .padding(.vertical, 12)
    }
}
