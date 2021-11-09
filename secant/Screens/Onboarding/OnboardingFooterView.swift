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
                        .frame(height: proxy.size.height / 12)
                        .padding(.horizontal, 15)
                        .transition(.opacity)
                    }
                    
                    ProgressView(
                        "\(viewStore.index + 1)/\(viewStore.steps.count)",
                        value: Double(viewStore.index + 1),
                        total: Double(viewStore.steps.count)
                    )
                    .onboardingProgressStyle
                    .padding(.horizontal, 30)
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
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 Pro Max")
            
            OnboardingFooterView(store: store)
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 13 mini")
        }
    }
}
