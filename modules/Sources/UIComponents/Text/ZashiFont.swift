//
//  ZashiFont.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-16-2024
//

import SwiftUI

import Generated

public struct ZashiFontModifier: ViewModifier {
    public enum FontWeight: Equatable {
        case black
        case blackItalic
        case bold
        case boldItalic
        case extraBold
        case extraBoldItalic
        case extraLight
        case extraLightItalic
        case italic
        case light
        case lightItalic
        case medium
        case mediumItalic
        case regular
        case semiBold
        case semiBoldItalic
        case thin
        case thinItalic
    }
    
    let weight: FontWeight
    let addressFont: Bool
    let size: CGFloat
    let style: Colorable

    public func body(content: Content) -> some View {
        content
            .font(.custom(fontName(weight, addressFont: addressFont), size: size))
            .foregroundColor(style.color)
    }
    
    private func fontName(_ weight: FontWeight, addressFont: Bool = false) -> String {
        if addressFont {
            switch weight {
            case .bold: return FontFamily.RobotoMono.bold.name
            case .medium: return FontFamily.RobotoMono.medium.name
            case .semiBold: return FontFamily.RobotoMono.semiBold.name
            default: return FontFamily.RobotoMono.regular.name
            }
        } else {
            switch weight {
            case .black: return FontFamily.Inter.black.name
            case .blackItalic: return FontFamily.Inter.blackItalic.name
            case .bold: return FontFamily.Inter.bold.name
            case .boldItalic: return FontFamily.Inter.boldItalic.name
            case .extraBold: return FontFamily.Inter.extraBold.name
            case .extraBoldItalic: return FontFamily.Inter.extraBoldItalic.name
            case .extraLight: return FontFamily.Inter.extraLight.name
            case .extraLightItalic: return FontFamily.Inter.extraLightItalic.name
            case .italic: return FontFamily.Inter.italic.name
            case .light: return FontFamily.Inter.light.name
            case .lightItalic: return FontFamily.Inter.lightItalic.name
            case .medium: return FontFamily.Inter.medium.name
            case .mediumItalic: return FontFamily.Inter.mediumItalic.name
            case .regular: return FontFamily.Inter.regular.name
            case .semiBold: return FontFamily.Inter.semiBold.name
            case .semiBoldItalic: return FontFamily.Inter.semiBoldItalic.name
            case .thin: return FontFamily.Inter.thin.name
            case .thinItalic: return FontFamily.Inter.thinItalic.name
            }
        }
    }
}

public extension View {
    func zFont(
        _ weight: ZashiFontModifier.FontWeight = .regular,
        addressFont: Bool = false,
        size: CGFloat,
        style: Colorable
    ) -> some View {
        self.modifier(
            ZashiFontModifier(weight: weight, addressFont: addressFont, size: size, style: style)
        )
    }
}
