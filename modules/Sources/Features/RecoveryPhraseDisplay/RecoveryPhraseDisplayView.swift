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
import MnemonicSwift

public struct RecoveryPhraseDisplayView: View {
    let store: RecoveryPhraseDisplayStore
    
    public init(store: RecoveryPhraseDisplayStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                Spacer()

                Asset.Assets.zashiLogo.image
                    .resizable()
                    .renderingMode(.template)
                    .tint(Asset.Colors.primary.color)
                    .frame(width: 33, height: 43)

                Spacer()

                if let groups = viewStore.phrase?.toGroups() {
                    VStack {
                        Text(L10n.RecoveryPhraseDisplay.titlePart1)
                            .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                        Text(L10n.RecoveryPhraseDisplay.titlePart2)
                            .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    }

                    Spacer()

                    Text(L10n.RecoveryPhraseDisplay.description)
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))

                    Spacer()
                    
                    HStack(spacing: 75) {
                        ForEach(groups, id: \.startIndex) { group in
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        ForEach(Array(group.words.enumerated()), id: \.offset) { seedWord in
                                            Text("\(seedWord.offset + group.startIndex + 1).")
                                                .font(.custom(FontFamily.Inter.medium.name, size: 16))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        ForEach(Array(group.words.enumerated()), id: \.offset) { seedWord in
                                            Text("\(seedWord.element.data)")
                                                .font(.custom(FontFamily.Inter.medium.name, size: 16))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()

                    if let birthdayValue = viewStore.birthdayValue {
                        Text(L10n.RecoveryPhraseDisplay.birthdayHeight(birthdayValue))
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    }

                    Spacer()
                    
                    Button(
                        action: { viewStore.send(.finishedPressed) },
                        label: { Text(L10n.RecoveryPhraseDisplay.Button.wroteItDown.uppercased()) }
                    )
                    .zcashStyle()
                    .frame(width: 236)
                    .padding(.bottom, 50)
                } else {
                    Text(L10n.RecoveryPhraseDisplay.noWords)
                    
                    Spacer()
                }
            }
            .applyScreenBackground()
            .padding(.horizontal, 60)
            .onAppear { viewStore.send(.onAppear) }
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .navigationBarHidden(viewStore.phrase?.toGroups() != nil)
            .zashiBack()
        }
    }
}

#Preview {
    NavigationView {
        RecoveryPhraseDisplayView(store: .placeholder)
    }
}
