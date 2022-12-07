//
//  OnboardingScreen.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/7/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingScreen: View {
    let store: Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>

    var body: some View {
        VStack {
            ZStack {
                OnboardingHeaderView(
                    store: store.scope(
                        state: { state in
                            OnboardingHeaderView.ViewState(
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
        }
        .navigationBarHidden(true)
        .applyScreenBackground()
    }
}

// MARK: - Previews

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
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
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        .environment(\.sizeCategory, .accessibilityLarge)

        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingFlowReducer.State(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingFlowReducer()
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}
