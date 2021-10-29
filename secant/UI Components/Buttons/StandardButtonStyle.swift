//
//  ButtonModifier.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/18/21.
//

import SwiftUI

struct StandardButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let background: Color
    let pressedBackgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 60,
                maxHeight: 60
            )
            .foregroundColor(foregroundColor)
            .background(
                configuration.isPressed ? pressedBackgroundColor : background
            )
            .cornerRadius(12)
    }
}

private extension Button {
    var exampleButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.button.color,
                background: Asset.Colors.Buttons.createButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.createButtonPressed.color
            )
        )
    }
}

struct ButtonModifier_Previews: PreviewProvider {
    static var previews: some View {
        Button("Example Button") { dump("Example button") }
            .exampleButtonStyle
            .padding(.horizontal, 25)
            .frame(height: 60)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)
    }
}
