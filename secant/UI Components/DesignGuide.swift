//
//  DesignGuide.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI

struct DesignGuide: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("H1 Onboarding Rubik Light")
                .font(FontFamily.Rubik.light.textStyle(.title))
                .foregroundColor(Asset.Colors.Text.titleText.color)
            Text("H1 Onboarding Rubik medium")
                .font(FontFamily.Rubik.medium.textStyle(.title))
                .foregroundColor(Asset.Colors.Text.titleText.color)
            Button(action: {}) {
                Text("Primary Button")
            }
            .primaryButtonStyle
            .frame(height: 50)

            Button(action: {}) {
                Text("Primary Active Button")
            }
            .createButtonStyle
            .frame(height: 50)

            Button(action: {}) {
                Text("Secondary Button")
            }
            .secondaryButtonStyle
            .frame(height: 50)

            Button(action: {}) {
                Text("Action Button")
            }
            .activeButtonStyle
            .frame(height: 50)
        }
        .padding(.horizontal, 30)
        .applyScreenBackground()
    }
}

struct DesignGuide_Previews: PreviewProvider {
    static var previews: some View {
        DesignGuide()
            .preferredColorScheme(.dark)

        DesignGuide()
            .preferredColorScheme(.light)
    }
}
