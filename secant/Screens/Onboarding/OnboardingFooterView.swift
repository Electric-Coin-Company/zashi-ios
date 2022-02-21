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
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack(spacing: 5) {
                    Spacer()
                    
                    if viewStore.isFinalStep {
                        Button("Create New Wallet") {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                viewStore.send(.createNewWallet)
                            }
                        }
                        .primaryButtonStyle
                        .frame(height: proxy.size.height / 12)
                        .padding(.horizontal, 15)
                        .transition(.opacity)
                    } else {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                viewStore.send(.next)
                            }
                        }
                        .primaryButtonStyle
                        .frame(height: 69)
                        .padding(.horizontal, 28)
                        .transition(.opacity)
                    }
                    
                    ProgressView(
                        "0\(viewStore.index + 1)",
                        value: Double(viewStore.index + 1),
                        total: Double(viewStore.steps.count)
                    )
                    .onboardingProgressStyle
                    .padding(.horizontal, 28)
                    .padding([.vertical], 20)
                }
            }
        }
    }
}

struct OnboardingFooterView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<OnboardingState, OnboardingAction>(
            initialState: OnboardingState(index: 0),
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
