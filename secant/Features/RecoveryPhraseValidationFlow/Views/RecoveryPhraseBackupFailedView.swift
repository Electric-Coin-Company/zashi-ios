//
//  ValidationFailed.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 12/22/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseBackupFailedView: View {
    @Environment(\.presentationMode) var presentationMode

    var store: RecoveryPhraseValidationFlowStore

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

                    Asset.Assets.Backgrounds.calloutBackupFailed.image
                        .frame(
                            width: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height),
                            height: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height)
                        )

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
                            action: {
                                viewStore.send(.reset)
                                presentationMode.wrappedValue.dismiss()
                            },
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
            .applyScreenBackground()
        }
    }
}

/// Following computations are necessary to handle properly sizing and positioning of elements
/// on different devices (aspects). iPhone SE and iPhone 8 are similar aspect family devices
/// while iPhone X, 11, etc are different family devices, capable to use more of the space.
extension RecoveryPhraseBackupFailedView {
    func circularFrameUniformSize(width: CGFloat, height: CGFloat) -> CGFloat {
        var deviceMultiplier = 1.0
        
        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = 1.0 + (((aspect / 1.51) - 1.0) * 2.0)
        }
        
        return width * 0.48 * deviceMultiplier
    }
}

// MARK: - Previews

struct RecoveryPhraseBackupValidationFailedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RecoveryPhraseBackupFailedView(store: .demo)
            }
            
            RecoveryPhraseBackupFailedView(store: .demo)
                .preferredColorScheme(.dark)
            
            RecoveryPhraseBackupFailedView(store: .demo)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            
            RecoveryPhraseBackupFailedView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)

            RecoveryPhraseBackupFailedView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        }
    }
}
