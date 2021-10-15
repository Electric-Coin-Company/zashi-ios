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
                    Button(
                        action: { viewStore.send(.backPressed) },
                        label: { Text("Previous") }
                    )
                    .disabled(viewStore.backButtonDisabled)
                    
                    Spacer()
                    
                    Button(
                        action: { viewStore.send(.nextPressed) },
                        label: { Text("Next") }
                    )
                    .disabled(viewStore.nextButtonDisabled)
                }
                .frame(height: 100)
                .padding(.horizontal, 50)
                
                Spacer()
                
                Text(viewStore.currentStep.imageName)
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
            OnboardingStep(
                id: UUID(),
                description: "This is the description of the first onboarding step, please read it carefully.",
                imageName: "Image"
            ),
            OnboardingStep(
                id: UUID(),
                description: "The second step is even more important, have to pay attention to the details here.",
                imageName: "Image"
            ),
            OnboardingStep(
                id: UUID(),
                description: "Congratulations you made it all the way through to the end, you can use the app now!",
                imageName: "Image"
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
