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
                        .frame(width: circularFrameUniformSize, height: circularFrameUniformSize)
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
                        .offset(y: viewStore.offset - height / circularFrameOffsetCoeffcient)
                        .transition(.scale(scale: 2).combined(with: .opacity))
                }
            }
            ZStack {
                ForEach(0..<viewStore.steps.count) { stepIndex in
                    VStack(spacing: viewStore.isFinalStep ? 50 : 15) {
                        HStack {
                            Text(viewStore.steps[stepIndex].title)
                                .titleText()
                                .lineLimit(0)
                                .minimumScaleFactor(0.1)
                            if !viewStore.isFinalStep {
                                Spacer()
                            }
                        }
                        
                        Text(viewStore.steps[stepIndex].description)
                            .paragraphText()
                            .lineSpacing(2)
                            .opacity(0.53)
                    }
                    .opacity(stepIndex == viewStore.index ? 1: 0)
                    .padding(.horizontal, 35)
                    .frame(width: width, height: height)
                }
            }
            .offset(y: viewStore.isFinalStep ? width / 2.5 : viewStore.offset + height / descriptionOffsetCoefficient)
        }
    }
}

/// Following computations are necessary to handle properly sizing and positioning of elements
/// on different devices (apects). iPhone SE and iPhone 8 are similar aspect family devices
/// while iPhone X, 11, etc are different family devices, capable to use more of the space.
extension OnboardingContentView {
    var circularFrameUniformSize: CGFloat {
        var deviceMultiplier = 1.0
        
        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = 1.0 + (((aspect / 1.725) - 1.0) * 2.0)
        }
        
        return width * 0.6 * deviceMultiplier
    }

    var circularFrameOffsetCoeffcient: CGFloat {
        var deviceMultiplier = 1.0

        if width > 0.0 {
            let aspect = height / width
            deviceMultiplier = aspect / 1.725
        }

        return 4.4 * deviceMultiplier
    }

    var descriptionOffsetCoefficient: Double {
        if width > 0.0 {
            let aspect = height / width
            let deviceMultiplier = 1.0 + (((aspect / 1.725) - 1.0) * 2.5)
            
            if abs(deviceMultiplier) > 0.0 {
                return 8.0 / deviceMultiplier
            }
        }
        
        return 8.0
    }
}

struct OnboardingContentView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
            initialState: OnboardingState(
                index: 0,
                importWalletState: .placeholder
            ),
            reducer: OnboardingReducer.default,
            environment: ()
        )
        
        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))

        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))

        OnboardingContentView_Previews.example(store)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
    }
}

extension OnboardingContentView_Previews {
    static func example(_ store: Store<OnboardingState, OnboardingAction>) -> some View {
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
