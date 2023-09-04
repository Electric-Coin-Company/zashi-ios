//
//  ButtonModifier.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/18/21.
//

import SwiftUI
import Generated

public struct StandardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    let foregroundColor: Color
    let background: Color
    let pressedBackgroundColor: Color
    let disabledBackgroundColor: Color
    
    let overlayColor: Color

    public init(
        foregroundColor: Color,
        background: Color,
        pressedBackgroundColor: Color,
        disabledBackgroundColor: Color,
        overlayColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.background = background
        self.pressedBackgroundColor = pressedBackgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.overlayColor = overlayColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
                    Rectangle()
                        .frame(height: 60)
                        .overlay(
                            Rectangle()
                                .border(Color.black)
                                .foregroundColor(overlayColor)
                                .offset(y: 8)
                                .padding(.trailing, -10)
                                .padding(.leading, 13)
                        )
                    configuration.label
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity
                        )
                        .frame(height: 60)
                        .foregroundColor(foregroundColor)
                        .background(background)
                        .border(Color.black)
        }
    }
}

private extension Button {
    var exampleButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.button.color,
                background: Asset.Colors.Buttons.activeButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color,
                overlayColor: Asset.Colors.Text.button.color
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
            .preferredColorScheme(.light)
    }
}
