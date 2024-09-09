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
    @Perception.Bindable var store: StoreOf<OnboardingFlow>

    public init(store: StoreOf<OnboardingFlow>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
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
                    store.send(.createNewWallet)
                }
                .zcashStyle()
                .padding(.bottom, 30)

                Button(L10n.PlainOnboarding.Button.restoreWallet.uppercased()) {
                    store.send(.importExistingWallet)
                }
                .zcashStyle(.secondary)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 70)
            .navigationLinkEmpty(
                isActive: store.bindingFor(.importExistingWallet),
                destination: {
                    ImportWalletView(
                        store: store.scope(
                            state: \.importWalletState,
                            action: \.importWallet
                        )
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingFor(.createNewWallet),
                destination: {
                    SecurityWarningView(
                        store: store.scope(
                            state: \.securityWarningState,
                            action: \.securityWarning
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
                initialState: OnboardingFlow.State(
                    walletConfig: .initial,
                    importWalletState: .initial,
                    securityWarningState: .initial
                )
            ) {
                OnboardingFlow()
            }
    )
}

// MARK: - ViewStore

extension StoreOf<OnboardingFlow> {
    func bindingFor(_ destination: OnboardingFlow.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}

// MARK: Placeholders

extension OnboardingFlow.State {
    public static var initial: Self {
        .init(
            walletConfig: .initial,
            importWalletState: .initial,
            securityWarningState: .initial
        )
    }
}
