//
//  OnboardingScreen.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/7/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingScreen: View {
    let store: OnboardingFlowStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    OnboardingHeaderView(
                        store: store.scope(
                            state: { state in
                                OnboardingHeaderView.ViewState(
                                    walletConfig: state.walletConfig,
                                    isInitialStep: state.isInitialStep,
                                    isFinalStep: state.isFinalStep
                                )
                            },
                            action: { action in
                                switch action {
                                case .back: return .back
                                case .skip: return .skip
                                }
                            }
                        )
                    )
                    .zIndex(1)
                    
                    OnboardingContentView(store: store)
                }
                
                Spacer()
                
                OnboardingFooterView(store: store)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .applyScreenBackground()
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

// MARK: - Previews

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    walletConfig: .default,
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    walletConfig: .default,
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    walletConfig: .default,
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
