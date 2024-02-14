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
    let disabled: Bool
    
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
                                .foregroundColor(
                                    disabled 
                                    ? Asset.Colors.shade72.color
                                    : Asset.Colors.primary.color
                                )
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        }
                    }
                    .disabled(disabled)
                }
            }
    }
}

extension View {
    public func zashiBack(_ disabled: Bool = false) -> some View {
        modifier(ZashiBackModifier(disabled: disabled))
    }
}
