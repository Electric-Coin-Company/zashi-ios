//
//  SuccessView.swift
//  secant-testnet
//
//  Created by Adam Stener on 12/8/21.
//

import SwiftUI
import ComposableArchitecture

struct ValidationSucceededView: View {
    var store: RecoveryPhraseValidationStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(spacing: 20) {
                        Text("validationSuccess.title")
                            .titleText()
                            .multilineTextAlignment(.center)

                        Text("validationSuccess.description")
                            .paragraphText()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 45)
                    }
                    .padding(.vertical, 40)

                    VStack {
                        CircularFrame()
                            .backgroundImage(
                                Asset.Assets.Backgrounds.calloutBackupSucceeded.image
                            )
                            .frame(
                                width: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height),
                                height: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height)
                            )
                            .badgeIcon(.shield)
                    }
                    .padding(.bottom, 40)

                    Spacer()

                    VStack(spacing: 15) {
                        Button(
                            action: {
                                viewStore.send(.proceedToHome, animation: .easeIn(duration: 1))
                            },
                            label: {
                                Text("validationSuccess.button.goToWallet")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        )
                        .activeButtonStyle
                        .validationSucceededViewLayout()
                        
                        Button(
                            action: {
                                viewStore.send(
                                    .displayBackedUpPhrase,
                                    animation: .easeIn(duration: 1)
                                )
                            },
                            label: {
                                Text("validationSuccess.button.phraseAgain")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        )
                        .secondaryButtonStyle
                        .validationSucceededViewLayout()
                    }
                }
                .padding(.horizontal)
                .scrollableWhenScaledUp()
            }
        }
        .navigationBarHidden(true)
        .applySucceededScreenBackground()
    }
}

/// Following computations are necessary to handle properly sizing and positioning of elements
/// on different devices (apects). iPhone SE and iPhone 8 are similar aspect family devices
/// while iPhone X, 11, etc are different family devices, capable to use more of the space.
extension ValidationSucceededView {
    func circularFrameUniformSize(width: CGFloat, height: CGFloat) -> CGFloat {
        var deviceMultiplier = 1.0
        
        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = 1.0 + (((aspect / 1.51) - 1.0) * 2.0)
        }
        
        return width * 0.48 * deviceMultiplier
    }
}

// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate struct ValidationSucceededViewLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 64,
                maxHeight: .infinity,
                alignment: .center
            )
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 28)
            .transition(.opacity)
    }
}

extension View {
    func validationSucceededViewLayout() -> some View {
        modifier(ValidationSucceededViewLayout())
    }
}

struct ValidationSuccededView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ValidationSucceededView(store: .demo)
            }
            
            ValidationSucceededView(store: .demo)
                .preferredColorScheme(.dark)
            
            ValidationSucceededView(store: .demo)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
            
            ValidationSucceededView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)

            ValidationSucceededView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        }
    }
}
