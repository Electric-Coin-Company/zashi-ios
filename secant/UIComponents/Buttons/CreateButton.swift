//
//  PrimaryButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

extension Button {
    var createButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.button.color,
                background: Asset.Colors.Buttons.createButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.createButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.createButtonDisabled.color
            )
        )
    }
}

struct CreateButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Create Button") { dump("Create button") }
            .createButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
        
        Button("Create Button") { dump("Create button") }
            .createButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)
    }
}
