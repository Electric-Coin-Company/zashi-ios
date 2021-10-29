//
//  SecantTextStyles.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/28/21.
//

import Foundation
import SwiftUI

extension View {
    func bodyText() -> some View {
        self.modifier(BodyTextStyle())
    }

    func titleText() -> some View {
        self.modifier(TitleTextStyle())
    }
}

/**
Body text style. Used for content.  Roboto-Regular 18pt
*/
struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Text.body.color)
            .font(.custom(FontFamily.Rubik.regular.name, size: 18))
    }
}

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Text.body.color)
            .font(.custom(FontFamily.Roboto.medium.name, size: 24))
    }
}
