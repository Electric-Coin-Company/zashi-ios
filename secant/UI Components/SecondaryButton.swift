//
//  PrimaryButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
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
                Asset.Colors.Buttons.secondaryButtonPressed.color :
                Asset.Colors.Buttons.secondaryButton.color
            )
            .cornerRadius(12)
    }
}

extension Button {
    var secondaryButtonStyle: some View {
        buttonStyle(SecondaryButtonStyle())
    }
}

struct SecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Secondary Button") { dump("Secondary button") }
            .secondaryButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
        
        Button("Secondary Button") { dump("Secondary button") }
            .secondaryButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)
    }
}
