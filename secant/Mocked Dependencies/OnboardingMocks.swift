//
//  OnboardingMocks.swift
//  secantTests
//
//  Created by Francisco Gindre on 9/20/21.
//

import Foundation
class OnboardingStepProviderBuilder {
    var steps: [OnboardingStep] = []
    var startingAt: Int = 0

    func add(_ step: OnboardingStep) -> Self {
        steps.append(step)
        return self
    }

    func starting(at step: Int) -> Self {
        precondition(step < steps.count)
        precondition(step > 0)
        self.startingAt = step
        return self
    }

    func build() -> OnboardingStepProviding {
        SequencedOnboardingStepProvider(
            steps: steps,
            startingAt: self.startingAt
        )
    }
}

extension OnboardingStep {
    static let stepZero = OnboardingStep(
        title: "First Onboarding Step",
        imageName: "figure.wave",
        blurb: "This is the first step of the Secant Wallet user onboarding",
        stepNumber: 0
    )

    static let stepOne = OnboardingStep(
        title: "Second Onboarding Step",
        imageName: "figure.wave",
        blurb: "This is the Second step of the Secant Wallet user onboarding",
        stepNumber: 1
    )
}

class SequencedOnboardingStepProvider: OnboardingStepProviding {
    var currentStepIndex: Int

    var steps: [OnboardingStep]

    var totalSteps: Int {
        self.steps.count
    }

    var currentStep: OnboardingStep {
        self.steps[currentStepIndex]
    }

    var hasNext: Bool {
        currentStepIndex < (steps.count - 1)
    }
    var hasPrevious: Bool {
        self.currentStepIndex > 0
    }

    init(
        steps: [OnboardingStep],
        startingAt index: Int = 0
    ) {
        self.steps = steps
        self.currentStepIndex = index
    }

    func next() {
        guard currentStepIndex < steps.count else { return }
        currentStepIndex += 1
    }

    func previous() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
    }
}
