//
//  ActiveButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

extension Button {
    var activeButtonStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.activeButtonText.color,
                background: Asset.Colors.Buttons.activeButton.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color
            )
        )
    }
}

struct ActiveButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Active Button") { dump("Active button") }
            .activeButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.light)
        
        Button("Active Button") { dump("Active button") }
            .activeButtonStyle
            .frame(width: 250, height: 50)
            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(.dark)
    }
}
