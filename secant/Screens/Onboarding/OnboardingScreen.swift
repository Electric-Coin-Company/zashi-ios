//
//  OnboardingScreen.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/7/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingScreen: View {
    let store: Store<OnboardingState, OnboardingAction>

    var body: some View {
        GeometryReader { proxy in
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
                
                OnboardingContentView(
                    store: store,
                    width: proxy.size.width,
                    height: proxy.size.height
                )
                
                OnboardingFooterView(store: store)
            }
        }
        .navigationBarHidden(true)
        .applyScreenBackground()
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.light)
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingScreen(
            store: Store(
                initialState: OnboardingState(
                    importWalletState: .placeholder
                ),
                reducer: OnboardingReducer.default,
                environment: (.demo)
            )
        )
        .preferredColorScheme(.dark)
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}
