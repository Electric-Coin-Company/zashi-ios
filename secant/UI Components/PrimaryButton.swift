//
//  PrimaryButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
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
                Asset.Colors.Buttons.primaryButtonPressed.color :
                Asset.Colors.Buttons.primaryButton.color
            )
            .cornerRadius(12)
    }
}

extension Button {
    var primaryButtonStyle: some View {
        buttonStyle(PrimaryButtonStyle())
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Primary Button") { dump("Primary button") }
            .primaryButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
        
        Button("Primary Button") { dump("Primary button") }
            .primaryButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)
    }
}

