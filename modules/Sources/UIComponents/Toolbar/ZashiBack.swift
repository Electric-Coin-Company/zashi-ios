//
//  ZashiBack.swift
//
//
//  Created by Lukáš Korba on 04.10.2023.
//

import SwiftUI
import Generated

struct ZashiBackModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.backward")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 10, height: 10)
                                .tint(Asset.Colors.primary.color)

                            Text(L10n.General.back.uppercased())
                                .foregroundColor(Asset.Colors.primary.color)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        }
                    }
                }
            }
    }
}

extension View {
    public func zashiBack() -> some View {
        modifier(ZashiBackModifier())
    }
}
