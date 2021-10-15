//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct OnboardingStep: Equatable, Identifiable {
    let id: UUID
    let description: String
    let imageName: String
}

struct OnboardingState: Equatable {
    var steps: IdentifiedArrayOf<OnboardingStep> = Self.onboardingSteps
    var index = 0
    var offset: CGFloat = .zero
    
    var currentStep: OnboardingStep { steps[index] }
    var nextButtonDisabled: Bool { steps.count == index + 1 }
    var backButtonDisabled: Bool { index == 0 }
    var progress: Int {
        ((index + 1) * 100) / (steps.count)
    }
}

enum OnboardingAction: Equatable {
    case nextPressed
    case backPressed
}

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, Void> { state, action, _ in
    switch action {
    case .backPressed:
        state.index -= 1
        state.offset += 20.0
        return .none
        
    case .nextPressed:
        state.index += 1
        state.offset -= 20.0
        return .none
    }
}
