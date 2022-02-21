//
//  OnboardingContentView.swift
//  secant-testnet
//
//  Created by Adam Stener on 11/18/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingContentView: View {
    let store: Store<OnboardingState, OnboardingAction>
    let width: Double
    let height: Double
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                if viewStore.isFinalStep {
                    VStack {
                        Asset.Assets.Backgrounds.callout4.image
                            .resizable()
                            .frame(
                                width: width,
                                height: height * 0.6
                            )
                            .aspectRatio(contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                        Spacer()
                    }
                    .transition(.opacity)
                } else {
                    CircularFrame()
                        .backgroundImages(
                            store.actionless.scope(
                                state: { state in
                                    CircularFrameBackgroundImages.ViewState(
                                        index: state.index,
                                        images: state.steps.map { $0.background }
                                    )
                                }
                            )
                        )
                        .frame(width: width * 0.82, height: width * 0.82)
                        .badgeIcons(
                            store.actionless.scope(
                                state: { state in
                                    BadgesOverlay.ViewState(
                                        index: state.index,
                                        badges: state.steps.map { $0.badge }
                                    )
                                }
                            )
                        )
                        .offset(y: viewStore.offset - height / 7)
                        .transition(.scale(scale: 2).combined(with: .opacity))
                }
            }
            ZStack {
                ForEach(0..<viewStore.steps.count) { stepIndex in
                    VStack(spacing: viewStore.isFinalStep ? 50 : 15) {
                        HStack {
                            Text(viewStore.steps[stepIndex].title)
                                .titleText()
                            if !viewStore.isFinalStep {
                                Spacer()
                            }
                        }
                        
                        Text(viewStore.steps[stepIndex].description)
                            .bodyText()
                            .opacity(0.53)
                    }
                    .opacity(stepIndex == viewStore.index ? 1: 0)
                    .padding(.horizontal, 35)
                    .frame(width: width, height: height)
                }
            }
            .offset(y: viewStore.isFinalStep ? width / 2.3 : viewStore.offset + width / 2.3)
        }
    }
}

struct OnboardingContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: OnboardingState(index: 0),
            reducer: OnboardingReducer.default,
            environment: ()
        )
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
            }
        }
        .applyScreenBackground()
        .preferredColorScheme(.light)
    }
}
