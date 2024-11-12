//
//  ActionRow.swift
//  Zashi
//
//  Created by Lukáš Korba on 22.08.2024.
//

import SwiftUI

import Generated

public struct ActionRow<AccessoryContent>: View where AccessoryContent: View{
    @Environment(\.isEnabled) private var isEnabled
    
    let icon: Image
    let title: String
    let desc: String?
    let customIcon: Bool
    @ViewBuilder let accessoryView: AccessoryContent?
    let divider: Bool
    let horizontalPadding: CGFloat
    let action: () -> Void
    
    public init(
        icon: Image,
        title: String,
        desc: String? = nil,
        customIcon: Bool = false,
        accessoryView: AccessoryContent? = EmptyView(),
        divider: Bool = true,
        horizontalPadding: CGFloat = 20,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.desc = desc
        self.customIcon = customIcon
        self.accessoryView = accessoryView
        self.divider = divider
        self.horizontalPadding = horizontalPadding
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
                        if let accessoryView {
                            HStack(spacing: 0) {
                                Text(title)
                                    .zFont(.semiBold, size: 16, style: Design.Text.primary)

                                accessoryView
                                    .padding(.leading, 8)
                            }
                        } else {
                            Text(title)
                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                        }
                        
                        if let desc {
                            Text(desc)
                                .zFont(size: 12, style: Design.Text.tertiary)
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
                .padding(.horizontal, horizontalPadding)

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
