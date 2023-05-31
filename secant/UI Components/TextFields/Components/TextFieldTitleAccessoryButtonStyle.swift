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
            .foregroundColor(.white)
            .background(
                configuration.isPressed ?
                Asset.Colors.TextField.titleAccessoryButtonPressed.color :
                Asset.Colors.TextField.titleAccessoryButton.color
            )
            .cornerRadius(6)
    }
}

extension Button {
    var textFieldTitleAccessoryButtonStyle: some View {
        buttonStyle(TextFieldTitleAccessoryButtonStyle())
    }
}
