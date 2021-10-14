//
//  PrimaryButton.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/14/21.
//

import SwiftUI

struct CreateButtonStyle: ButtonStyle {
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
                Asset.Colors.Buttons.createButtonPressed.color :
                Asset.Colors.Buttons.createButton.color
            )
            .cornerRadius(12)
    }
}

extension Button {
    var createButtonStyle: some View {
        buttonStyle(CreateButtonStyle())
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
