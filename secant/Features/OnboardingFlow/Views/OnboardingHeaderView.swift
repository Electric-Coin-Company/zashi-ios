//
//  OnboardingNavigationButtons.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/18/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingHeaderView: View {
    struct ViewState: Equatable {
        let isInitialStep: Bool
        let isFinalStep: Bool
    }
    
    enum ViewAction {
        case back
        case skip
    }
    
    let store: Store<ViewState, ViewAction>
    let animationDuration: CGFloat = 0.8
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                HStack {
                    if !viewStore.isInitialStep {
                        Button("Back") {
                            viewStore.send(.back, animation: .easeInOut(duration: animationDuration))
                        }
                        .navigationButtonStyle
                        .frame(width: 75)
                        .disabled(viewStore.isInitialStep)
                        .minimumScaleFactor(0.1)
                    }
                    
                    Spacer()
                    
                    if !viewStore.isInitialStep && !viewStore.isFinalStep {
                        Button("Skip") {
                            viewStore.send(.skip, animation: .easeInOut(duration: animationDuration))
                        }
                        .navigationButtonStyle
                        .disabled(viewStore.isFinalStep)
                        .frame(width: 75)
                        .minimumScaleFactor(0.1)
                    }
                }
                .padding(.horizontal, 30)
                .frame(height: 40)
                
                Spacer()
            }
        }
    }
}

// MARK: - Previews

struct OnboardingHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>(
            initialState: OnboardingFlowReducer.State(
                index: 0,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
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
        .preferredColorScheme(.light)
        .applyScreenBackground()
    }
}
