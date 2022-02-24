//
//  PrimaryButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

extension Button {
    var secondaryButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.secondaryButtonText.color,
                background: Asset.Colors.Buttons.secondaryButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.secondaryButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.secondaryButton.color
            )
        )
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
