//
//  ButtonModifier.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/18/21.
//

import SwiftUI

struct NavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
            .foregroundColor(Asset.Colors.Text.button.color)
            .background(
                configuration.isPressed ?
                    Asset.Colors.Buttons.onboardingNavigationPressed.color :
                    Asset.Colors.Buttons.onboardingNavigation.color
            )
            .cornerRadius(.infinity)
            .neumorphicButton(configuration.isPressed)
    }
}

extension Button {
    var navigationButtonStyle: some View {
        buttonStyle(
            NavigationButtonStyle()
        )
    }
}

struct NavigationModifier_Previews: PreviewProvider {
    static var previews: some View {
        Button("Back") { dump("Example button") }
            .navigationButtonStyle
            .frame(width: 80, height: 40)
            .applyScreenBackground()
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)

        Button("Skip") { dump("Example button") }
            .navigationButtonStyle
            .frame(width: 80, height: 40)
            .applyScreenBackground()
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
    }
}
