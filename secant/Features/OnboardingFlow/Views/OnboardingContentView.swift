//
//  OnboardingContentView.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/18/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingContentView: View {
    let store: Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            let image = viewStore.steps[viewStore.index].background
                .resizable()
                .scaledToFit()

            let title = Text(viewStore.steps[viewStore.index].title)
                .titleText()
                .lineLimit(0)
                .minimumScaleFactor(0.1)
                .padding(.vertical, 10)
            
            let text = Text(viewStore.steps[viewStore.index].description)
                .paragraphText()
                .lineSpacing(2)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, 20)
            
            if viewStore.isFinalStep {
                VStack {
                    HStack {
                        title
                            .padding(.top, 60)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    text
                    image
                }
            } else {
                VStack {
                    image
                    HStack {
                        title
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    text
                }
            }
        }
    }
}

struct OnboardingContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: OnboardingFlowReducer.State(
                index: 0,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}

// MARK: - Previews

extension OnboardingContentView_Previews {
    static func example(_ store: Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>) -> some View {
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
                store: store
            )
        }
        .applyScreenBackground()
        .preferredColorScheme(.light)
    }
}
