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

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(spacing: 10) {
                        Text("Success!")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 36))

                        Text("Place that backup somewhere safe and venture forth in security.")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 17))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .frame(width: proxy.size.width * 0.7)
                    }
                    .padding(.bottom, 75)

                    CircularFrame()
                        .backgroundImage(
                            Asset.Assets.Backgrounds.callout1.image
                        )
                        .frame(
                            width: proxy.size.width * 0.84,
                            height: proxy.size.width * 0.84
                        )
                        .badgeIcon(.shield)

                    Spacer()

                    VStack(spacing: 15) {
                        Button(
                            action: {
                                viewStore.send(.proceedToHome, animation: .easeIn(duration: 1))
                            },
                            label: { Text("Take me to my wallet!") }
                        )
                        .activeButtonStyle
                        .frame(
                            width: proxy.size.width * 0.8,
                            height: 60
                        )

                        Button(
                            action: { viewStore.send(.displayBackedUpPhrase, animation: .easeIn(duration: 1)) },
                            label: { Text("Show me my phrase again") }
                        )
                        .secondaryButtonStyle
                        .frame(
                            width: proxy.size.width * 0.8,
                            height: 60
                        )
                    }
                }
                .frame(width: proxy.size.width)
                .padding(.vertical, 20)
                .applyScreenBackground()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ValidationSuccededView_Previews: PreviewProvider {
    static var previews: some View {
        ValidationSuccededView(store: RecoveryPhraseValidationStore.demo)
    }
}
