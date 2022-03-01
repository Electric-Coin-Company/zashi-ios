//
//  RecoveryPhraseTestPreambleView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/01/22.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseTestPreambleView: View {
    var store: RecoveryPhraseValidationStore

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(alignment: .center, spacing: 20) {
                        Text("recoveryPhraseTestPreamble.title")
                            .titleText()
                            .multilineTextAlignment(.center)
                            
                        Text("recoveryPhraseTestPreamble.paragraph1")
                            .paragraphText()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 44)
                            .opacity(0.53)
                    }
                    .padding(.bottom, 20)

                    CircularFrame()
                        .backgroundImage(
                            Asset.Assets.Backgrounds.callout1.image
                        )
                        .frame(
                            width: proxy.size.width * 0.84,
                            height: proxy.size.width * 0.84
                        )
                        .badgeIcon(.error)

                    Spacer()

                    VStack(alignment: .center, spacing: 40) {
                        VStack(alignment: .center, spacing: 20) {
                            Text("recoveryPhraseTestPreamble.paragraph2")
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .opacity(0.53)

                            Text("recoveryPhraseTestPreamble.paragraph3")
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .opacity(0.53)
                        }

                        Button(
                            action: { viewStore.send(.recoveryBackupPhraseValidation) },
                            label: { Text("recoveryPhraseTestPreamble.button.goNext") }
                        )
                        .activeButtonStyle
                        .frame(width: nil, height: 60)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(width: proxy.size.width)
                .scrollableWhenScaledUp()
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForRoute(.recoveryBackupPhraseValidation),
                    destination: { RecoveryPhraseBackupValidationView(store: store) }
                )
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .applyScreenBackground()
        }
    }
}

struct RecoveryPhraseTestPreambleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecoveryPhraseTestPreambleView(store: .demo)

            RecoveryPhraseTestPreambleView(store: .demo)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

            RecoveryPhraseTestPreambleView(store: .demo)
                .environment(\.sizeCategory, .accessibilityLarge)
        }
    }
}
