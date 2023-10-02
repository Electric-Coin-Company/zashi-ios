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

public struct PlainOnboardingView: View {
    let store: OnboardingFlowStore
    let animationDuration: CGFloat = 0.8

    public init(store: OnboardingFlowStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(alignment: .leading, spacing: 80) {
                    Text(L10n.PlainOnboarding.title)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 34, relativeTo: .largeTitle)
                            .weight(.heavy)
                        )

                    Text(L10n.PlainOnboarding.caption)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 16, relativeTo: .body)
                            .weight(.semibold)
                        )
                }
                .padding(0)
                
                Spacer()
                
                Button(L10n.PlainOnboarding.Button.createNewWallet.uppercased()) {
                    viewStore.send(.createNewWallet, animation: .easeInOut(duration: animationDuration))
                }
                .zcashStyle()
                .padding(.horizontal, 70)
                .padding(.bottom, 30)

                Button(L10n.PlainOnboarding.Button.restoreWallet.uppercased()) {
                    viewStore.send(.importExistingWallet, animation: .easeInOut(duration: animationDuration))
                }
                .zcashStyle(.secondary)
                .padding(.horizontal, 70)
                .padding(.bottom, 20)
            }
            .padding(.all)
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
        }
    }
}

struct PlainOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlainOnboardingView(
                store: Store(
                    initialState: OnboardingFlowReducer.State(
                        walletConfig: .default,
                        importWalletState: .placeholder
                    ),
                    reducer: OnboardingFlowReducer(saplingActivationHeight: 0)
                )
            )
        }
    }
}
