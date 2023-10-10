//
//  ZashiTitle.swift
//
//
//  Created by Lukáš Korba on 06.10.2023.
//

import SwiftUI
import Generated

struct ZashiTitleModifier<ZashiTitleContent>: ViewModifier where ZashiTitleContent: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder let zashiTitleContent: ZashiTitleContent
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    zashiTitleContent
                }
            }
    }
}

extension View {
    public func zashiTitle(_ content: () -> some View) -> some View {
        modifier(ZashiTitleModifier(zashiTitleContent: content))
    }
}
