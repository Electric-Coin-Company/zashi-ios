//
//  OnboardingFooterView.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/18/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingFooterView: View {
    let store: Store<OnboardingState, OnboardingAction>
    let animationDuration: CGFloat = 0.8

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 5) {
                Spacer()
                
                if viewStore.isFinalStep {
                    Button("Create New Wallet") {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            viewStore.send(.createNewWallet)
                        }
                    }
                    .createButtonStyle
                    .buttonLayout()
                    
                    Button("Import an Existing Wallet") {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            viewStore.send(.createNewWallet)
                        }
                    }
                    .secondaryButtonStyle
                    .buttonLayout()
                } else {
                    Button("Next") {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            viewStore.send(.next)
                        }
                    }
                    .primaryButtonStyle
                    .buttonLayout()
                    
                    ProgressView(
                        "0\(viewStore.index + 1)",
                        value: Double(viewStore.index + 1),
                        total: Double(viewStore.steps.count)
                    )
                        .onboardingProgressStyle
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                }
            }
        }
    }
}

struct OnboardingFooterButtonLayout: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 60)
            .padding(.horizontal, 28)
            .transition(.opacity)
    }
}

extension View {
    func buttonLayout() -> some View {
        modifier(OnboardingFooterButtonLayout())
    }
}

struct OnboardingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<OnboardingState, OnboardingAction>(
            initialState: OnboardingState(index: 3),
            reducer: OnboardingReducer.default,
            environment: ()
        )
        
        Group {
            OnboardingFooterView(store: store)
                .applyScreenBackground()
                .preferredColorScheme(.light)
                .previewDevice("iPhone 13 Pro Max")

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
