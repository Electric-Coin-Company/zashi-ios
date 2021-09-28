//
//  OnboardingScreenViewModel.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 9/17/21.
//

import Foundation
import Combine

struct OnboardingStep {
    var title: String?
    var imageName: String
    var blurb: String
    var stepNumber: Int
}

class OnboardingScreenViewModel: BaseViewModel<OnboardingStepProvider>, ObservableObject {
    enum RightBarButton {
        case skip
        case close
        case none
    }
    
    @Published var currentStep: OnboardingStep

    var totalSteps: Int {
        services.totalSteps
    }

    var showPreviousButton: Bool {
        services.hasPrevious
    }

    var showNextButton: Bool {
        services.hasNext
    }

    var showRightBarButton: RightBarButton {
        services.hasNext ? .skip : .close
    }

    var showStepper: Bool {
        services.totalSteps > 1
    }

    override init(services: OnboardingStepProvider) {
        self.currentStep = services.currentStep
        super.init(services: services)
    }

    func next() {
        services.next()
        self.currentStep = services.currentStep
    }

    func previous() {
        services.previous()
        self.currentStep = services.currentStep
    }

    func skip() {}
}

extension OnboardingStep: Equatable {}
