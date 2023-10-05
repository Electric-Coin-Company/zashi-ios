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
                                .renderingMode(.template)
                                .tint(Asset.Colors.primary.color)

                            Text("BACK")
                                .foregroundColor(Asset.Colors.primary.color)
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
