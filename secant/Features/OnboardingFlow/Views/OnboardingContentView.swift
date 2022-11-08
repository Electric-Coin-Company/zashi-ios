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
    let width: Double
    let height: Double
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            let scale = imageScale
            let imageWidth: CGFloat = width * scale
            let imageXOffset: CGFloat = (width - imageWidth) / 2

            let image = viewStore.steps[viewStore.index].background
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageWidth)
                .offset(x: imageXOffset)

            let title = Text(viewStore.steps[viewStore.index].title)
                .titleText()
                .lineLimit(0)
                .minimumScaleFactor(0.1)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))

            let text = Text(viewStore.steps[viewStore.index].description)
                .paragraphText()
                .lineSpacing(2)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))

            if viewStore.isFinalStep {
                VStack(alignment: .leading) {
                    title
                        .padding(.top, 73 * imageScale)
                    text
                    image
                    Spacer()
                }
            } else {
                VStack(alignment: .leading) {
                    image
                    title
                    text
                    Spacer()
                }
            }
        }
    }
}

/// Following computations are necessary to handle properly sizing and positioning of elements
/// on different devices (apects). iPhone SE and iPhone 8 are similar aspect family devices
/// while iPhone X, 11, etc are different family devices, capable to use more of the space.
extension OnboardingContentView {
    var imageScale: CGFloat {
        // Just to be sure that we counting with exactly 3 decimal points.
        let aspectRatio = (floor(height / width * 1000)) / 1000

        /// iPhone SE or iPhone 8 for example
        if aspectRatio <= 1.725 {
            return 0.7
        } else {
            return 1.0
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
