//
//  TextFieldTitleAccessoryButtonStyle.swift
//  secant-testnet
//
//  Created by Adam Stener on 2/9/22.
//

import SwiftUI
import Generated

struct TextFieldTitleAccessoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .foregroundColor(Asset.Colors.primary.color)
            .background(
                configuration.isPressed ?
                Asset.Colors.primary.color :
                Asset.Colors.primary.color
            )
            .cornerRadius(6)
    }
}

extension Button {
    public var textFieldTitleAccessoryButtonStyle: some View {
        buttonStyle(TextFieldTitleAccessoryButtonStyle())
    }
}
