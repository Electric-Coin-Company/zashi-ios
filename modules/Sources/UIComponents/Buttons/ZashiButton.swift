//
//  ZashiButton.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-12-2024.
//

import SwiftUI

import Generated

public struct ZashiButton<PrefixContent, AccessoryContent>: View where PrefixContent: View, AccessoryContent: View {
    public enum `Type` {
        case primary
        case secondary
        case tertiary
        case quaternary
        case destructive1
        case destructive2
        case brand
        case ghost
    }
    
    @Environment(\.isEnabled) var isEnabled
    
    let title: String
    let type: `Type`
    let infinityWidth: Bool
    @ViewBuilder let prefixView: PrefixContent?
    @ViewBuilder let accessoryView: AccessoryContent?
    let action: () -> Void

    public init(
        _ title: String,
        type: `Type` = .primary,
        infinityWidth: Bool = true,
        prefixView: PrefixContent? = EmptyView(),
        accessoryView: AccessoryContent? = EmptyView(),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.infinityWidth = infinityWidth
        self.accessoryView = accessoryView
        self.prefixView = prefixView
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                if let prefixView {
                    prefixView
                        .padding(.trailing, 8)
                }

                Text(title)
                    .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                
                if let accessoryView {
                    accessoryView
                        .padding(.leading, 8)
                }
            }
            .foregroundColor(fgColor())
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: infinityWidth ? .infinity : nil)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor())
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(strokeColor())
                    }
            }
        }
    }
    
    private func bgColor() -> Color {
        switch type {
        case .primary:
            return isEnabled
            ? Design.Btns.Primary.bg.color
            : Design.Btns.Primary.bgDisabled.color
        case .secondary:
            return isEnabled
            ? Design.Btns.Secondary.bg.color
            : Design.Btns.Secondary.bgDisabled.color
        case .tertiary:
            return isEnabled
            ? Design.Btns.Tertiary.bg.color
            : Design.Btns.Tertiary.bgDisabled.color
        case .quaternary:
            return isEnabled
            ? Design.Btns.Quaternary.bg.color
            : Design.Btns.Quaternary.bgDisabled.color
        case .destructive1:
            return isEnabled
            ? Design.Btns.Destructive1.bg.color
            : Design.Btns.Destructive1.bgDisabled.color
        case .destructive2:
            return isEnabled
            ? Design.Btns.Destructive2.bg.color
            : Design.Btns.Destructive2.bgDisabled.color
        case .brand:
            return isEnabled
            ? Design.Btns.Brand.bg.color
            : Design.Btns.Brand.bgDisabled.color
        case .ghost:
            return isEnabled
            ? Design.Btns.Ghost.bg.color
            : Design.Btns.Ghost.bgDisabled.color
        }
    }
    
    private func fgColor() -> Color {
        switch type {
        case .primary:
            return isEnabled
            ? Design.Btns.Primary.fg.color
            : Design.Btns.Primary.fgDisabled.color
        case .secondary:
            return isEnabled
            ? Design.Btns.Secondary.fg.color
            : Design.Btns.Secondary.fgDisabled.color
        case .tertiary:
            return isEnabled
            ? Design.Btns.Tertiary.fg.color
            : Design.Btns.Tertiary.fgDisabled.color
        case .quaternary:
            return isEnabled
            ? Design.Btns.Quaternary.fg.color
            : Design.Btns.Quaternary.fgDisabled.color
        case .destructive1:
            return isEnabled
            ? Design.Btns.Destructive1.fg.color
            : Design.Btns.Destructive1.fgDisabled.color
        case .destructive2:
            return isEnabled
            ? Design.Btns.Destructive2.fg.color
            : Design.Btns.Destructive2.fgDisabled.color
        case .brand:
            return isEnabled
            ? Design.Btns.Brand.fg.color
            : Design.Btns.Brand.fgDisabled.color
        case .ghost:
            return isEnabled
            ? Design.Btns.Ghost.fg.color
            : Design.Btns.Ghost.fgDisabled.color
        }
    }

    private func strokeColor() -> Color {
        switch type {
        case .primary:
            return isEnabled
            ? Design.Btns.Primary.bg.color
            : Design.Btns.Primary.bgDisabled.color
        case .secondary:
            return isEnabled
            ? Design.Btns.Secondary.border.color
            : Design.Btns.Secondary.bgDisabled.color
        case .tertiary:
            return isEnabled
            ? Design.Btns.Tertiary.bg.color
            : Design.Btns.Tertiary.bgDisabled.color
        case .quaternary:
            return isEnabled
            ? Design.Btns.Quaternary.bg.color
            : Design.Btns.Quaternary.bgDisabled.color
        case .destructive1:
            return isEnabled
            ? Design.Btns.Destructive1.border.color
            : Design.Btns.Destructive1.bgDisabled.color
        case .destructive2:
            return isEnabled
            ? Design.Btns.Destructive2.bg.color
            : Design.Btns.Destructive2.bgDisabled.color
        case .brand:
            return isEnabled
            ? Design.Btns.Brand.bg.color
            : Design.Btns.Brand.bgDisabled.color
        case .ghost:
            return isEnabled
            ? Design.Btns.Ghost.bg.color
            : Design.Btns.Ghost.bgDisabled.color
        }
    }
}

#Preview {
    VStack(spacing: 15) {
        ZashiButton("Button") {}
        ZashiButton("Button", type: .secondary) {}
        ZashiButton("Button", type: .tertiary) {}
        ZashiButton("Button", type: .quaternary) {}
        ZashiButton("Button", type: .destructive1) {}
        ZashiButton("Button", type: .destructive2) {}
        ZashiButton("Button", type: .brand) {}
        ZashiButton("Button", type: .ghost) {}
    }
    .screenHorizontalPadding()
}

#Preview {
    VStack(spacing: 15) {
        ZashiButton(
            "Button",
            prefixView: 
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .secondary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .tertiary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .quaternary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .destructive1,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .destructive2,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .brand,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
        
        ZashiButton(
            "Button",
            type: .ghost,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
    }
    .screenHorizontalPadding()
}

#Preview {
    VStack(spacing: 15) {
        ZashiButton(
            "Button",
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .secondary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .tertiary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .quaternary,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .destructive1,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .destructive2,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .brand,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
        
        ZashiButton(
            "Button",
            type: .ghost,
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary),
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Text.primary)
        ) {}
            .disabled(true)
    }
    .screenHorizontalPadding()
}
