//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct OnboardingState: Equatable {
    struct Step: Equatable, Identifiable {
        let id: UUID
        let title: LocalizedStringKey
        let description: LocalizedStringKey
        let background: Image
        let badge: Badge
    }

    var steps: IdentifiedArrayOf<Step> = Self.onboardingSteps
    var index = 0
    var skippedAtindex: Int?
    
    var currentStep: Step { steps[index] }
    var isFinalStep: Bool { steps.count == index + 1 }
    var isInitialStep: Bool { index == 0 }
    var progress: Int { ((index + 1) * 100) / (steps.count) }
    var offset: CGFloat {
        let maxOffset = CGFloat(-60)
        let stepOffset = CGFloat(maxOffset / CGFloat(steps.count - 1))
        guard index != 0 else { return .zero }
        return stepOffset * CGFloat(index)
    }
}

enum OnboardingAction: Equatable {
    case next
    case back
    case skip
    case createNewWallet
    case importExistingWallet
}

typealias OnboardingReducer = Reducer<OnboardingState, OnboardingAction, Void>

extension OnboardingReducer {
    static let `default` = Reducer<OnboardingState, OnboardingAction, Void> { state, action, _ in
        switch action {
        case .back:
            guard state.index > 0 else { return .none }
            if let skippedFrom = state.skippedAtindex {
                state.index = skippedFrom
                state.skippedAtindex = nil
            } else {
                state.index -= 1
            }
            return .none
            
        case .next:
            guard state.index < state.steps.count - 1 else { return .none }
            state.index += 1
            return .none
            
        case .skip:
            guard state.skippedAtindex == nil else { return .none }
            state.skippedAtindex = state.index
            state.index = state.steps.count - 1
            return .none
            
        case .createNewWallet:
            return .none

        case .importExistingWallet:
            return .none
        }
    }
}
