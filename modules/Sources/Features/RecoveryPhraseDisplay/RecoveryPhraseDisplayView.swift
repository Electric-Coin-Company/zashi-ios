//
//  RecoveryPhraseDisplayView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct RecoveryPhraseDisplayView: View {
    let store: RecoveryPhraseDisplayStore
    
    public init(store: RecoveryPhraseDisplayStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                if let groups = viewStore.phrase?.toGroups(groupSizeOverride: 2) {
                    VStack(spacing: 20) {
                        Text(L10n.RecoveryPhraseDisplay.title)
                            .font(
                                .custom(FontFamily.Inter.regular.name, size: 20)
                                .weight(.bold)
                            )
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(L10n.RecoveryPhraseDisplay.description)
                                .font(
                                    .custom(FontFamily.Inter.regular.name, size: 16)
                                )
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 20)
                    
                    Spacer()

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(groups, id: \.startIndex) { group in
                            VStack {
                                HStack(alignment: .center) {
                                    HStack {
                                        Spacer()
                                        Text("\(group.startIndex). \(group.words[0].data)")
                                        Spacer()
                                    }
                                    .padding(.leading, 20)
                                    HStack {
                                        Spacer()
                                        Text("\(group.startIndex + 1). \(group.words[1].data)")
                                        Spacer()
                                    }
                                    .padding(.trailing, 20)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(
                            action: { viewStore.send(.finishedPressed) },
                            label: { Text(L10n.RecoveryPhraseDisplay.Button.wroteItDown.uppercased()) }
                        )
                        .zcashStyle()
                        .padding(.horizontal, 70)
                    }
                    .padding()
                } else {
                    Text(L10n.RecoveryPhraseDisplay.noWords)
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
    public static var demo: RecoveryPhraseDisplayStore {
        RecoveryPhraseDisplayStore(
            initialState: .init(phrase: .placeholder),
            reducer: RecoveryPhraseDisplayReducer.demo,
            environment: Void()
        )
    }
}

struct RecoveryPhraseDisplayView_Previews: PreviewProvider {
    static let scheduler = DispatchQueue.main
    static let store = RecoveryPhraseDisplayStore.demo

    static var previews: some View {
        NavigationView {
            RecoveryPhraseDisplayView(store: store)
        }
    }
}
