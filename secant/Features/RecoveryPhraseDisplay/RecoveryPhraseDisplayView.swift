//
//  RecoveryPhraseDisplayView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseDisplayView: View {
    let store: RecoveryPhraseDisplayStore
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    if let groups = viewStore.phrase?.toGroups() {
                        VStack(spacing: 20) {
                            Text("recoveryPhraseDisplay.title")
                                .titleText()
                                .multilineTextAlignment(.center)

                            VStack(alignment: .center, spacing: 4) {
                                Text("recoveryPhraseDisplay.description")
                                    .bodyText()
                                
                                Text("recoveryPhraseDisplay.backItUp")
                                    .bodyText()
                            }
                        }
                        .padding(.top, 0)
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 35) {
                            ForEach(groups, id: \.startIndex) { group in
                                VStack {
                                    WordChipGrid(words: group.words, startingAt: group.startIndex)
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                        
                        VStack {
                            Button(
                                action: { viewStore.send(.finishedPressed) },
                                label: { Text("recoveryPhraseDisplay.button.finished") }
                            )
                            .activeButtonStyle
                            .frame(height: 60)
                            
                            Button(
                                action: {
                                    viewStore.send(.copyToBufferPressed)
                                },
                                label: {
                                    Text("recoveryPhraseDisplay.button.copyToBuffer")
                                        .bodyText()
                                }
                            )
                            .frame(height: 60)
                        }
                        .padding()
                    } else {
                        Text("recoveryPhraseDisplay.noWords")
                    }
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal)
            .padding(.top, 0)
            .applyScreenBackground()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}
// TODO: [#695] This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight https://github.com/zcash/ZcashLightClientKit/issues/695
extension RecoveryPhraseDisplayStore {
    static var demo: RecoveryPhraseDisplayStore {
        RecoveryPhraseDisplayStore(
            initialState: .init(phrase: .placeholder),
            reducer: RecoveryPhraseDisplayReducer.demo,
            environment: Void()
        )
    }
}

// TODO: [#695] This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight https://github.com/zcash/ZcashLightClientKit/issues/695
extension RecoveryPhrase {
    static let testPhrase = [
        // 1
        "bring", "salute", "thank",
        "require", "spirit", "toe",
        // 7
        "boil", "hill", "casino",
        "trophy", "drink", "frown",
        // 13
        "bird", "grit", "close",
        "morning", "bind", "cancel",
        // 19
        "daughter", "salon", "quit",
        "pizza", "just", "garlic"
    ]

    static let placeholder = RecoveryPhrase(words: testPhrase)
    static let empty = RecoveryPhrase(words: [])
}

struct RecoveryPhraseDisplayView_Previews: PreviewProvider {
    static let scheduler = DispatchQueue.main
    static let store = RecoveryPhraseDisplayStore.demo

    static var previews: some View {
        NavigationView {
            RecoveryPhraseDisplayView(store: store)
        }
        .environment(\.sizeCategory, .accessibilityLarge)

        NavigationView {
            RecoveryPhraseDisplayView(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
