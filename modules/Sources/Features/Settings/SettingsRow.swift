//
//  SettingsRow.swift
//  Zashi
//
//  Created by Lukáš Korba on 22.08.2024.
//

import SwiftUI

import Generated

public struct SettingsRow: View {
    @Environment(\.isEnabled) private var isEnabled
    
    var icon: Image
    var title: String
    var desc: String?
    var customIcon: Bool
    var divider: Bool
    var action: () -> Void
    
    init(
        icon: Image,
        title: String,
        desc: String? = nil,
        customIcon: Bool = false,
        divider: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.desc = desc
        self.customIcon = customIcon
        self.divider = divider
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if customIcon {
                        icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 16)
                    } else {
                        icon
                            .zImage(size: 20, style: Design.Text.primary)
                            .padding(10)
                            .background {
                                Circle()
                                    .fill(Design.Surfaces.bgTertiary.color)
                            }
                            .padding(.trailing, 16)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                            .foregroundColor(Design.Text.primary.color)
                        
                        if let desc {
                            Text(desc)
                                .font(.custom(FontFamily.Inter.regular.name, size: 12))
                                .foregroundColor(Design.Text.tertiary.color)
                                .lineSpacing(1.2)
                                .padding(.top, 2)
                        }
                    }

                    Spacer(minLength: 2)
                    
                    if isEnabled {
                        Asset.Assets.chevronRight.image
                            .zImage(size: 20, style: Design.Text.quaternary)
                    }
                }
                .padding(.horizontal, 20)

                if divider {
                    Design.Surfaces.divider.color
                        .frame(height: 1)
                        .padding(.top, 12)
                }
            }
        }
        .padding(.top, 12)
        .background(Asset.Colors.background.color)
    }
}
