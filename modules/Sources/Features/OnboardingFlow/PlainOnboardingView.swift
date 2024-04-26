//
//  PlainOnboardingView.swift
//  secant
//
//  Created by Francisco Gindre on 3/13/23.
//

import SwiftUI
import ComposableArchitecture
import Generated
import ImportWallet
import SecurityWarning
import ZcashLightClientKit

public struct PlainOnboardingView: View {
    let store: OnboardingFlowStore

    public init(store: OnboardingFlowStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Asset.Assets.welcomeScreenLogo.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 169, height: 160)
                    .padding(.top, 10)
                    .foregroundColor(Asset.Colors.primary.color)

                Text(L10n.PlainOnboarding.title)
                    .font(.custom(FontFamily.Inter.regular.name, size: 22))
                    .padding(.top, 15)
                    .multilineTextAlignment(.center)

                Spacer()
                
                Button(L10n.PlainOnboarding.Button.createNewWallet.uppercased()) {
                    viewStore.send(.createNewWallet)
                }
                .zcashStyle()
                .padding(.bottom, 30)

                Button(L10n.PlainOnboarding.Button.restoreWallet.uppercased()) {
                    viewStore.send(.importExistingWallet)
                }
                .zcashStyle(.secondary)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 70)
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.importExistingWallet),
                destination: {
                    ImportWalletView(
                        store: store.scope(
                            state: \.importWalletState,
                            action: OnboardingFlowReducer.Action.importWallet
                        )
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.createNewWallet),
                destination: {
                    SecurityWarningView(
                        store: store.scope(
                            state: \.securityWarningState,
                            action: OnboardingFlowReducer.Action.securityWarning
                        )
                    )
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
    }
}

#Preview {
    PlainOnboardingView(
        store:
            Store(
                initialState: OnboardingFlowReducer.State(
                    walletConfig: .initial,
                    importWalletState: .initial,
                    securityWarningState: .initial
                )
            ) {
                OnboardingFlowReducer()
            }
    )
}
