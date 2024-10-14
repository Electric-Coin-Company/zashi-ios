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
    let size: CGFloat
    let style: Colorable

    public func body(content: Content) -> some View {
        content
            .font(.custom(fontName(weight), size: size))
            .foregroundColor(style.color)
    }
    
    private func fontName(_ weight: FontWeight) -> String {
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

public extension View {
    func zFont(
        _ weight: ZashiFontModifier.FontWeight = .regular,
        size: CGFloat,
        style: Colorable
    ) -> some View {
        self.modifier(
            ZashiFontModifier(weight: weight, size: size, style: style)
        )
    }
}
