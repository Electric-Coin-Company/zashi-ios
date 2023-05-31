//
//  RecoveryPhraseValidationFlowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/01/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct RecoveryPhraseValidationFlowView: View {
    var store: RecoveryPhraseValidationFlowStore

    public init(store: RecoveryPhraseValidationFlowStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    VStack(alignment: .center, spacing: 20) {
                        Text(L10n.RecoveryPhraseTestPreamble.title)
                            .titleText()
                            .multilineTextAlignment(.center)
                            
                        Text(L10n.RecoveryPhraseTestPreamble.paragraph1)
                            .paragraphText()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 44)
                            .opacity(0.53)
                    }
                    .padding(.bottom, 40)

                    Asset.Assets.Backgrounds.calloutBackupFlow1.image
                        .frame(
                            width: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height),
                            height: circularFrameUniformSize(width: proxy.size.width, height: proxy.size.height)
                        )

                    Spacer()

                    VStack(alignment: .center, spacing: 40) {
                        VStack(alignment: .center, spacing: 20) {
                            Text(L10n.RecoveryPhraseTestPreamble.paragraph2)
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .opacity(0.53)

                            Text(L10n.RecoveryPhraseTestPreamble.paragraph3)
                                .paragraphText()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                                .opacity(0.53)
                        }

                        Button(
                            action: { viewStore.send(.updateDestination(.validation)) },
                            label: { Text(L10n.RecoveryPhraseTestPreamble.Button.goNext) }
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
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(width: proxy.size.width)
                .scrollableWhenScaledUp()
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForValidation,
                    destination: {
                        RecoveryPhraseBackupView(store: store)
                    }
                )
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
extension RecoveryPhraseValidationFlowView {
    func circularFrameUniformSize(width: CGFloat, height: CGFloat) -> CGFloat {
        var deviceMultiplier = 1.0
        
        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = 1.0 + (((aspect / 1.51) - 1.0) * 2.8)
        }
        
        return width * 0.4 * deviceMultiplier
    }
}

struct RecoveryPhraseTestPreambleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RecoveryPhraseValidationFlowView(store: .demo)
            }

            RecoveryPhraseValidationFlowView(store: .demo)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
        }
    }
}
