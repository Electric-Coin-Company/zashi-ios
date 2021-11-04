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
    let title: String
    let description: String
}

struct OnboardingState: Equatable {
    var steps: IdentifiedArrayOf<OnboardingStep> = Self.onboardingSteps
    var index = 0
    var offset: CGFloat = .zero
    var skippedAtindex: Int?
    
    var currentStep: OnboardingStep { steps[index] }
    var skipButtonDisabled: Bool { steps.count == index + 1 }
    var backButtonDisabled: Bool { index == 0 }
    var progress: Int { ((index + 1) * 100) / (steps.count) }
}

enum OnboardingAction: Equatable {
    case next
    case back
    case skip
    case createNewWallet
}

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, Void> { state, action, _ in
    switch action {
    case .back:
        guard state.index > 0 else { return .none }
        if let skippedFrom = state.skippedAtindex {
            state.index = skippedFrom
            state.skippedAtindex = nil
        } else {
            state.index -= 1
            state.offset += 20.0
        }
        return .none
        
    case .next:
        guard state.index < state.steps.count - 1 else { return .none }
        state.index += 1
        state.offset -= 20.0
        return .none
        
    case .skip:
        state.skippedAtindex = state.index
        state.index = state.steps.count - 1
        return .none
        
    case .createNewWallet:
        return .none
    }
}
