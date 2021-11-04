//
//  Onboarding.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/12/21.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    let store: Store<OnboardingState, OnboardingAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 50) {
                HStack(spacing: 50) {
                    Button("Back") { viewStore.send(.back) }
                        .disabled(viewStore.backButtonDisabled)
                    
                    Spacer()
                    
                    Button("Skip") { viewStore.send(.skip) }
                        .disabled(viewStore.skipButtonDisabled)
                }
                .frame(height: 100)
                .padding(.horizontal, 50)
                
                Spacer()
                
                Text(viewStore.currentStep.title)
                    .frame(maxWidth: .infinity)
                    .offset(y: viewStore.offset)
                    .animation(.easeOut(duration: 0.4))
                
                Spacer()
                
                VStack {
                    Text(viewStore.currentStep.description)
                    
                    ProgressView(
                        "Progress \(viewStore.progress)%",
                        value: Double(viewStore.index + 1),
                        total: Double(viewStore.steps.count)
                    )
                    .padding(.horizontal, 25)
                    .padding(.vertical, 50)
                }
                .animation(.easeOut(duration: 0.2))
            }
        }
    }
}

// swiftlint:disable line_length
extension OnboardingState {
    static let onboardingSteps = IdentifiedArray(
        uniqueElements: [
            OnboardingStep(
                id: UUID(),
                title: "Shielded by Default",
                description: "Tired of worrying about which wallet you used last? US TOO! Now you don't have to, as all funds will automatically be moved to your shielded wallet (and migrated for you)."
            ),
            OnboardingStep(
                id: UUID(),
                title: "Unified Addresses",
                description: "Tired of worrying about which wallet you used last? US TOO! Now you don't have to, as all funds will automatically be moved to your shielded wallet (and migrated for you)."
            ),
            OnboardingStep(
                id: UUID(),
                title: "And so much more...",
                description: "Faster reverse syncing (yes it's a thing).  Liberated Payments, Social Payments, Address Books, in-line ZEC requests, wrapped Bitcoin, fractionalize NFTs, you providing liquidity for anything you want, getting that Defi, and going to Mexico."
            ),
            OnboardingStep(
                id: UUID(),
                title: "Ready for the Future",
                description: "Lets get you set up!"
            )
        ]
    )
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView(
                store: Store(
                    initialState: OnboardingState(),
                    reducer: onboardingReducer,
                    environment: ()
                )
            )
        }
    }
}
