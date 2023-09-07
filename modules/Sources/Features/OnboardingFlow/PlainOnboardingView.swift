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
                
                //Commenting Following Two text and Adding Image and Text accroding to updated Figma Design
//                VStack(alignment: .leading, spacing: 80) {
//                    Text(L10n.PlainOnboarding.title)
//                        .font(
//                            .custom(FontFamily.Inter.regular.name, size: 34, relativeTo: .largeTitle)
//                            .weight(.heavy)
//                        )
//
//                    Text(L10n.PlainOnboarding.caption)
//                        .font(
//                            .custom(FontFamily.Inter.regular.name, size: 16, relativeTo: .body)
//                            .weight(.semibold)
//                        )
//                }
//                .padding(0)
                VStack(spacing: 27) {
                    Image(Asset.Assets.welcomeScreenLogo.name)
                        .resizable()
                        .frame(width: 150, height: 150)
                    Text(L10n.WelcomeScreen.description)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 22)
                            .weight(.regular)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .frame(width: 277, height: 147, alignment: .top)
                    Spacer()
                }
                .padding(.top, 75.0)
                
                Spacer()
                
                VStack(spacing: 23) {
                    Button(L10n.PlainOnboarding.Button.createNewWallet.uppercased()) {
                        viewStore.send(.createNewWallet, animation: .easeInOut(duration: animationDuration))
                    }
                    .activeButtonStyle
                    .font(
                        .custom(FontFamily.Inter.medium.name, size: 14)
                        .weight(.medium)
                    )
                    .frame(height: 70)
                    
                    Button(L10n.PlainOnboarding.Button.restoreWallet.uppercased()) {
                        viewStore.send(.importExistingWallet, animation: .easeInOut(duration: animationDuration))
                    }
                    .activeWhiteButtonStyle
                    .font(
                        .custom(FontFamily.Inter.medium.name, size: 14)
                        .weight(.medium)
                    )
                    .frame(height: 70)
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                }
                .padding(EdgeInsets(top: 0.0, leading: 50.0, bottom: 0, trailing: 50.0))
                
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
