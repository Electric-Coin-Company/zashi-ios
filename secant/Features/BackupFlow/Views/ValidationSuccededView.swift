//
//  SuccessView.swift
//  secant-testnet
//
//  Created by Adam Stener on 12/8/21.
//

import SwiftUI
import ComposableArchitecture

struct ValidationSuccededView: View {
    var store: RecoveryPhraseValidationStore
    @ScaledMetric var scaledPadding: CGFloat = 10
    @ScaledMetric var scaledButtonHeight: CGFloat = 130
    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(spacing: 20) {
                        Text("Success!")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 36))

                        Text("Place that backup somewhere safe and venture forth in security.")
                            .bodyText()
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    VStack {
                        CircularFrame()
                            .backgroundImage(
                                Asset.Assets.Backgrounds.callout1.image
                            )
                            .frame(
                                width: proxy.size.width * 0.84,
                                height: proxy.size.width * 0.84
                            )
                            .badgeIcon(.shield)
                    }
                    .padding(.vertical, 20)

                    Spacer()

                    VStack(spacing: 15) {
                        Button(
                            action: {
                                viewStore.send(.proceedToHome, animation: .easeIn(duration: 1))
                            },
                            label: {
                                Text("Take me to my wallet!")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        )
                        .activeButtonStyle
                        .frame(
                            minHeight: 60,
                            idealHeight: 60,
                            maxHeight: .infinity
                        )

                        Button(
                            action: { viewStore.send(.displayBackedUpPhrase, animation: .easeIn(duration: 1)) },
                            label: {
                                Text("Show me my phrase again")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        )
                        .secondaryButtonStyle
                        .frame(
                            minHeight: 60,
                            idealHeight: 60,
                            maxHeight: .infinity
                        )
                    }
                    .frame(height: scaledButtonHeight)
                    .padding(.vertical, scaledPadding)
                }

                .padding(.horizontal)
                .scrollableWhenScaledUp()
            }
        }
        .navigationBarBackButtonHidden(true)
        .applyScreenBackground()
    }
}

struct ValidationSuccededView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ValidationSuccededView(store: RecoveryPhraseValidationStore.demo)
            ValidationSuccededView(store: RecoveryPhraseValidationStore.demo)
                .environment(\.sizeCategory, .accessibilityExtraLarge)
        }
    }
}
