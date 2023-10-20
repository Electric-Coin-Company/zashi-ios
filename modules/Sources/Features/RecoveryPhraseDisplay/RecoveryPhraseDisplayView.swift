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
            VStack(alignment: .center) {
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
                    
                    HStack {
                        ForEach(groups, id: \.startIndex) { group in
                            VStack(alignment: .leading) {
                                HStack(spacing: 2) {
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
                                                .minimumScaleFactor(0.5)
                                        }
                                    }
                                    
                                    if group.startIndex == 0 {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 15)

                    Spacer()

                    if let birthdayValue = viewStore.birthdayValue {
                        Text(L10n.RecoveryPhraseDisplay.birthdayHeight(birthdayValue))
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    }

                    Spacer()
                    
                    Button(L10n.RecoveryPhraseDisplay.Button.wroteItDown.uppercased()) {
                        viewStore.send(.finishedPressed)
                    }
                    .zcashStyle()
                    .padding(.bottom, 50)
                } else {
                    Text(L10n.RecoveryPhraseDisplay.noWords)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden()
            .applyScreenBackground()
            .padding(.horizontal, 60)
            .onAppear { viewStore.send(.onAppear) }
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .toolbarAction {
                Button {
                    viewStore.send(.copyToBufferPressed)
                } label: {
                    Text(L10n.AddressDetails.tapToCopy)
                        .font(.custom(FontFamily.Inter.bold.name, size: 11))
                        .underline()
                        .foregroundColor(Asset.Colors.primary.color)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        RecoveryPhraseDisplayView(store: .placeholder)
    }
}
