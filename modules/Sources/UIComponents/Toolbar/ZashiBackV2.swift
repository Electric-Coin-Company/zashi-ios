//
//  ZashiBack.swift
//
//
//  Created by Lukáš Korba on 04.10.2023.
//

import SwiftUI
import Generated

struct ZashiBackV2Modifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    let disabled: Bool
    let hidden: Bool
    let invertedColors: Bool
    let customDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        if hidden {
            content
                .navigationBarBackButtonHidden(true)
        } else {
            content
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if let customDismiss {
                                customDismiss()
                            } else {
                                dismiss()
                            }
                        } label: {
                            if invertedColors {
                                Asset.Assets.buttonCloseX.image
                                    .zImage(size: 24, color: Asset.Colors.ZDesign.shark100.color)
                                    .padding(8)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Asset.Colors.ZDesign.shark900.color)
                                    }
                            } else {
                                Asset.Assets.buttonCloseX.image
                                    .zImage(size: 24, style: Design.Btns.Tertiary.fg)
                                    .padding(8)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Design.Btns.Tertiary.bg.color)
                                    }
                            }
                        }
                        .disabled(disabled)
                    }
                }
        }
    }
}

extension View {
    public func zashiBackV2(
        _ disabled: Bool = false,
        hidden: Bool = false,
        invertedColors: Bool = false,
        customDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            ZashiBackV2Modifier(
                disabled: disabled,
                hidden: hidden,
                invertedColors: invertedColors,
                customDismiss: customDismiss
            )
        )
    }
}
