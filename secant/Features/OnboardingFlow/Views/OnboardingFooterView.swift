//
//  OnboardingFooterView.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/18/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingFooterView: View {
    let store: Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>
    let animationDuration: CGFloat = 0.8

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 5) {
                if viewStore.isFinalStep {
                    Button("onboarding.button.newWallet") {
                        viewStore.send(.createNewWallet, animation: .easeInOut(duration: animationDuration))
                    }
                    .activeButtonStyle
                    .onboardingFooterButtonLayout()
                    .minimumScaleFactor(0.1)

                    Button("onboarding.button.importWallet") {
                        viewStore.send(.importExistingWallet, animation: .easeInOut(duration: animationDuration))
                    }
                    .secondaryButtonStyle
                    .onboardingFooterButtonLayout()
                    .minimumScaleFactor(0.1)
                } else {
                    Button("Next") {
                        viewStore.send(.next, animation: .easeInOut(duration: animationDuration))
                    }
                    .primaryButtonStyle
                    .onboardingFooterButtonLayout()
                    .minimumScaleFactor(0.1)

                    ProgressView(
                        String(format: "%02d", viewStore.index + 1),
                        value: Double(viewStore.index + 1),
                        total: Double(viewStore.steps.count)
                    )
                    .onboardingProgressStyle
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                }
            }
            .padding(.top, 10)
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

// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate struct OnboardingFooterButtonLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 60)
            .padding(.horizontal, 28)
            .transition(.opacity)
    }
}

extension View {
    func onboardingFooterButtonLayout() -> some View {
        modifier(OnboardingFooterButtonLayout())
    }
}

// MARK: - Previews

struct OnboardingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>(
            initialState: OnboardingFlowReducer.State(
                index: 3,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        Group {
            OnboardingFooterView(store: store)
                .applyScreenBackground()
                .preferredColorScheme(.light)
                .previewDevice("iPhone 14 Pro")
                .environment(\.sizeCategory, .accessibilityLarge)

            OnboardingFooterView(store: store)
                .applyScreenBackground()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
            
            OnboardingFooterView(store: store)
                .applyScreenBackground()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 mini")
        }
    }
}
