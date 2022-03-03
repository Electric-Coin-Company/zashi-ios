//
//  ValidationFailed.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 12/22/21.
//

import SwiftUI
import ComposableArchitecture

struct ValidationFailedView: View {
    var store: RecoveryPhraseValidationStore

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(alignment: .center, spacing: 20) {
                        Text("validationFailed.title")
                            .titleText()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)

                    CircularFrame()
                        .backgroundImage(
                            Asset.Assets.Backgrounds.calloutBackupFailed.image
                        )
                        .frame(
                            width: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height),
                            height: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height)
                        )
                        .badgeIcon(.error)

                    Spacer()

                    VStack(alignment: .center, spacing: 40) {
                        VStack(alignment: .center, spacing: 20) {
                            Text("validationFailed.description")
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)

                            Text("validationFailed.incorrectBackupDescription")
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        Button(
                            action: { viewStore.send(.reset) },
                            label: { Text("validationFailed.button.tryAgain") }
                        )
                        .activeButtonStyle
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 64,
                            maxHeight: .infinity,
                            alignment: .center
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 28)
                    }
                    
                    Spacer()
                }
                .scrollableWhenScaledUp()
            }
            .padding()
            .navigationBarHidden(true)
            .applyErredScreenBackground()
        }
        .preferredColorScheme(.light)
    }
}

/// Following computations are necessary to handle properly sizing and positioning of elements
/// on different devices (apects). iPhone SE and iPhone 8 are similar aspect family devices
/// while iPhone X, 11, etc are different family devices, capable to use more of the space.
extension ValidationFailedView {
    func circularFrameUniformSize(width: CGFloat, height: CGFloat) -> CGFloat {
        var deviceMultiplier = 1.0
        
        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = 1.0 + (((aspect / 1.51) - 1.0) * 2.0)
        }
        
        return width * 0.48 * deviceMultiplier
    }
}

struct ValidationFailed_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ValidationFailedView(store: .demo)
            }
            
            ValidationFailedView(store: .demo)
                .preferredColorScheme(.dark)
            
            ValidationFailedView(store: .demo)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            
            ValidationFailedView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)

            ValidationFailedView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        }
    }
}
