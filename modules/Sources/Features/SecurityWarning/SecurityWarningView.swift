//
//  SecurityWarningView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import RecoveryPhraseDisplay

public struct SecurityWarningView: View {
    @Perception.Bindable var store: StoreOf<SecurityWarning>
    
    public init(store: StoreOf<SecurityWarning>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                Group {
                    Text(L10n.SecurityWarning.title)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                        .padding(.top, 40)
                        .padding(.bottom, 15)
                    
                    VStack(alignment: .leading) {
                        Text(L10n.SecurityWarning.warningA(store.appVersion, store.appBuild))
                            .font(.custom(FontFamily.Inter.medium.name, size: 16))
                        
                        Text(L10n.SecurityWarning.warningB)
                            .font(.custom(FontFamily.Inter.medium.name, size: 16))
                            .padding(.top, 20)
                        
                        Group {
                            Text(L10n.SecurityWarning.warningC)
                                .font(.custom(FontFamily.Inter.bold.name, size: 11))
                            + Text(L10n.SecurityWarning.warningD)
                                .font(.custom(FontFamily.Inter.medium.name, size: 11))
                        }
                        .padding(.top, 20)
                    }
                    
                    HStack {
                        ZashiToggle(
                            isOn: $store.isAcknowledged,
                            label: L10n.SecurityWarning.acknowledge
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    .padding(.leading, 1)
                    
                    ZashiButton(L10n.SecurityWarning.confirm) {
                        store.send(.confirmTapped)
                    }
                    .disabled(!store.isAcknowledged)
                    .padding(.vertical, 50)
                }
            }
            .padding(.vertical, 1)
            .zashiBack()
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationLinkEmpty(
                isActive: $store.recoveryPhraseDisplayViewBinding,
                destination: {
                    RecoveryPhraseDisplayView(
                        store: store.scope(
                            state: \.recoveryPhraseDisplayState,
                            action: \.recoveryPhraseDisplay
                        )
                    )
                }
            )
            .onAppear { store.send(.onAppear) }
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.SecurityWarning.screenTitle.uppercased())
    }
}

// MARK: - Previews

#Preview {
    SecurityWarningView(store: SecurityWarning.demo)
}

// MARK: - Store

extension SecurityWarning {
    public static var demo = StoreOf<SecurityWarning>(
        initialState: .placeholder
    ) {
        SecurityWarning()
    }
}

// MARK: - Placeholders

extension SecurityWarning.State {
    public static let placeholder = SecurityWarning.State(
        recoveryPhraseDisplayState: RecoveryPhraseDisplay.State(phrase: .placeholder)
    )
    
    public static let initial = SecurityWarning.State(
        recoveryPhraseDisplayState: RecoveryPhraseDisplay.State(
            phrase: .initial
        )
    )
}
