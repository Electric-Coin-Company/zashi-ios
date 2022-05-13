//
//  ButtonModifier.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/18/21.
//

import SwiftUI

struct StandardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    let foregroundColor: Color
    let background: Color
    let pressedBackgroundColor: Color
    let disabledBackgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: Asset.Colors.Buttons.buttonsTitleShadow.color, radius: 2, x: 0, y: 2)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
            .foregroundColor(foregroundColor)
            .background(
                isEnabled ?
                (configuration.isPressed ? pressedBackgroundColor : background)
                : disabledBackgroundColor
            )
            .cornerRadius(12)
            .neumorphicButton(configuration.isPressed)
    }
}

private extension Button {
    var exampleButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.button.color,
                background: Asset.Colors.Buttons.activeButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color
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
