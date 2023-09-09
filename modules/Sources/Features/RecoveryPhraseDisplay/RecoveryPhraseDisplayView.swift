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
            VStack(alignment: .center, spacing: 30) {
                if let groups = viewStore.phrase?.toGroups(groupSizeOverride: 2) {
                    
                    
                    Asset.Assets.zashiLogo.image
                        .resizable()
                        .frame(width: 33, height: 43)
                    
                    
                    VStack(alignment: .center, spacing: 10) {
                        
                        
                        VStack(spacing: 10) {
                            Text(L10n.RecoveryPhraseDisplay.title)
                                .font(
                                    .custom(FontFamily.Inter.regular.name, size: 25)
                                    .weight(.bold)
                                )
                                .multilineTextAlignment(.center)
                                
                            VStack(alignment: .center, spacing: 4) {
                                Text(L10n.RecoveryPhraseDisplay.description)
                                    .font(
                                        .custom(FontFamily.Inter.regular.name, size: 14)
                                    )
                                    .frame(height: 100)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 0)
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(groups, id: \.startIndex) { group in
                                VStack {
                                    HStack(alignment: .center) {
                                        HStack {
                                            Spacer()
                                            Text("\(group.startIndex). \(group.words[0].data)")
                                                .font(
                                                    .custom(FontFamily.Inter.regular.name, size: 16)
                                                )
                                            Spacer()
                                        }
                                        .padding(.leading, 20)
                                        HStack {
                                            Spacer()
                                            Text("\(group.startIndex + 1). \(group.words[1].data)")
                                                .font(
                                                    .custom(FontFamily.Inter.regular.name, size: 16)
                                                )
                                            Spacer()
                                        }
                                        .padding(.trailing, 20)
                                    }
                                }
                            }
                        }
                        
                    }

                    Text(L10n.RecoveryPhraseDisplay.subtext)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 14)
                        )
                    Button(
                        action: { viewStore.send(.finishedPressed) },
                        label: { Text(L10n.RecoveryPhraseDisplay.Button.wroteItDown) }
                    )
                    .activeButtonStyle
                    .frame(height: 70)
                    .padding(EdgeInsets(top: 10.0, leading: 50.0, bottom: 60.0, trailing: 50.0))
                } else {
                    Text(L10n.RecoveryPhraseDisplay.noWords)
                }
            }
//            .padding(.bottom, 0)
//            .padding(.horizontal)
//            .padding(.top, 0)
//            .applyScreenBackground()
        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarHidden(true)
        .applyScreenBackground()
        .replaceNavigationBackButton()
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
