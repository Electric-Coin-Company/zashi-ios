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
        .linearGradientBackground()
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
