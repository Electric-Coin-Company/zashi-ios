//
//  SecantTextStyles.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/28/21.
//

import Foundation
import SwiftUI
import Generated

extension Text {
    public func captionText() -> some View {
        self.modifier(CaptionTextStyle())
    }

    public func bodyText() -> some View {
        self.modifier(BodyTextStyle())
    }

    public func titleText() -> some View {
        self.modifier(TitleTextStyle())
    }

    public func paragraphText() -> some View {
        self.modifier(ParagraphStyle())
    }

    /// Body text style. Used for content.  Roboto-Regular 18pt
    private struct BodyTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(Asset.Colors.Text.body.color)
                .font(.custom(FontFamily.Rubik.regular.name, size: 18))
        }
    }

    /// Used for additional information, explanations, context (usually paragraphs)
    private struct ParagraphStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(Asset.Colors.Text.heading.color)
                .font(.custom(FontFamily.Rubik.regular.name, size: 16))
        }
    }

    private struct TitleTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(Asset.Colors.Text.heading.color)
                .font(.custom(FontFamily.Rubik.medium.name, size: 24, relativeTo: .callout))
                .shadow(color: Asset.Colors.Text.captionTextShadow.color, radius: 1, x: 0, y: 1)
        }
    }

    private struct CaptionTextStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(Asset.Colors.Text.captionText.color)
                .font(.custom(FontFamily.Rubik.regular.name, size: 16))
                .shadow(color: Asset.Colors.Text.captionTextShadow.color, radius: 1, x: 0, y: 1)
        }
    }
}
