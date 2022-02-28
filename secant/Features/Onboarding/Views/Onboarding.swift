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
                        .disabled(viewStore.isInitialStep)
                    
                    Spacer()
                    Button("Next") { viewStore.send(.next) }
                    
                    Button("Skip") { viewStore.send(.skip) }
                        .disabled(viewStore.isFinalStep)
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

extension OnboardingState {
    static let onboardingSteps = IdentifiedArray(
        uniqueElements: [
            Step(
                id: UUID(),
                title: "onboarding.step1.title",
                description: "onboarding.step1.description",
                background: Asset.Assets.Backgrounds.callout1.image,
                badge: .shield
            ),
            Step(
                id: UUID(),
                title: "onboarding.step2.title",
                description: "onboarding.step2.description",
                background: Asset.Assets.Backgrounds.callout2.image,
                badge: .person
            ),
            Step(
                id: UUID(),
                title: "onboarding.step3.title",
                description: "onboarding.step3.description",
                background: Asset.Assets.Backgrounds.callout3.image,
                badge: .list
            ),
            Step(
                id: UUID(),
                title: "onboarding.step4.title",
                description: "onboarding.step4.description",
                background: Asset.Assets.Backgrounds.callout4.image,
                badge: .shield
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
                    reducer: .default,
                    environment: ()
                )
            )
        }
    }
}
