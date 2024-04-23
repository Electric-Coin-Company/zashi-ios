//
//  SettingsRow.swift
//  Zashi
//
//  Created by Lukáš Korba on 22.08.2024.
//

import SwiftUI

import Generated

public struct SettingsRow: View {
    var icon: Image
    var iconTint: Color
    var iconBcg: Color
    var title: String
    var divider: Bool
    var action: () -> Void
    
    init(
        icon: Image,
        iconTint: Color = Asset.Colors.V2.textPrimary.color,
        iconBcg: Color = Asset.Colors.V2.bgTertiary.color,
        title: String,
        divider: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.iconBcg = iconBcg
        self.title = title
        self.divider = divider
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    icon
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(iconTint)
                        .padding(10)
                        .background {
                            Circle()
                                .fill(iconBcg)
                        }
                        .padding(.trailing, 16)

                    Text(title)
                        .font(.custom(FontFamily.Archivo.semiBold.name, size: 16))
                        .foregroundColor(Asset.Colors.V2.textPrimary.color)

                    Spacer(minLength: 2)
                    
                    Asset.Assets.chevronRight.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Asset.Colors.V2.textQuaternary.color)
                }
                .padding(.horizontal, 20)

                if divider {
                    Asset.Colors.V2.divider.color
                        .frame(height: 1)
                        .padding(.top, 12)
                }
            }
        }
        .padding(.top, 12)
        .background(Asset.Colors.background.color)
    }
}
