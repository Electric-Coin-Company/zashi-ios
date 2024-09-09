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
import Utils

public struct RecoveryPhraseDisplayView: View {
    @Perception.Bindable var store: StoreOf<RecoveryPhraseDisplay>
    
    public init(store: StoreOf<RecoveryPhraseDisplay>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            WithPerceptionTracking {
                VStack(alignment: .center) {
                    ZashiIcon()
                    
                    if let groups = store.phrase?.toGroups() {
                        VStack {
                            Text(L10n.RecoveryPhraseDisplay.titlePart1)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                            Text(L10n.RecoveryPhraseDisplay.titlePart2)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                        }
                        .padding(.bottom, 15)
                        
                        Text(L10n.RecoveryPhraseDisplay.description)
                            .font(.custom(FontFamily.Inter.medium.name, size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 15)

                        HStack {
                            ForEach(groups, id: \.startIndex) { group in
                                VStack(alignment: .leading) {
                                    HStack(spacing: 2) {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            ForEach(Array(group.words.enumerated()), id: \.offset) { seedWord in
                                                Text("\(seedWord.offset + group.startIndex + 1).")
                                                    .fixedSize()
                                                    .font(.custom(FontFamily.Inter.medium.name, size: 16))
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            ForEach(Array(group.words.enumerated()), id: \.offset) { seedWord in
                                                Text("\(seedWord.element.data)")
                                                    .fixedSize()
                                                    .font(.custom(FontFamily.Inter.medium.name, size: 16))
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
                        .padding(.bottom, 15)

                        if let birthdayValue = store.birthdayValue {
                            Text(L10n.RecoveryPhraseDisplay.birthdayHeight(birthdayValue))
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                .padding(.bottom, 15)
                        }
                    } else {
                        Text(L10n.RecoveryPhraseDisplay.noWords)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 35)
                    }

                    if !store.showBackButton {
                        Button(L10n.RecoveryPhraseDisplay.Button.wroteItDown.uppercased()) {
                            store.send(.finishedPressed)
                        }
                        .zcashStyle()
                        .padding(.bottom, 50)
                    }
                }
                .padding(.horizontal, 60)
                .onAppear { store.send(.onAppear) }
                .alert($store.scope(state: \.alert, action: \.alert))
                .zashiBack(false, hidden: !store.showBackButton)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical, 1)
        .applyScreenBackground(withPattern: true)
    }
}

#Preview {
    NavigationView {
        RecoveryPhraseDisplayView(
            store:
                StoreOf<RecoveryPhraseDisplay>(
                    initialState: RecoveryPhraseDisplay.State(
                        phrase: .placeholder,
                        showBackButton: true,
                        birthdayValue: nil
                    )
                ) {
                    RecoveryPhraseDisplay()
                }
        )
    }
}

// MARK: Placeholders

extension RecoveryPhraseDisplay.State {
    public static let initial = RecoveryPhraseDisplay.State(
        phrase: nil,
        birthday: nil
    )
}

extension RecoveryPhraseDisplay {
    public static let placeholder = StoreOf<RecoveryPhraseDisplay>(
        initialState: .initial
    ) {
        RecoveryPhraseDisplay()
    }
}
