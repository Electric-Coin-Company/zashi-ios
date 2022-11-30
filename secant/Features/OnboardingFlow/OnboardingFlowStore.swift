//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture

typealias OnboardingFlowStore = Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>
typealias OnboardingFlowViewStore = ViewStore<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>

struct OnboardingFlowReducer: ReducerProtocol {
    struct State: Equatable {
        enum Destination: Equatable, CaseIterable {
            case createNewWallet
            case importExistingWallet
        }
        
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
        var destination: Destination?

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
        
        /// Import Wallet
        var importWalletState: ImportWalletReducer.State
    }

    enum Action: Equatable {
        case next
        case back
        case skip
        case updateDestination(OnboardingFlowReducer.State.Destination?)
        case createNewWallet
        case importExistingWallet
        case importWallet(ImportWalletReducer.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.importWalletState, action: /Action.importWallet) {
            ImportWalletReducer()
        }
        
        Reduce { state, action in
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
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .createNewWallet:
                state.destination = .createNewWallet
                return .none

            case .importExistingWallet:
                state.destination = .importExistingWallet
                return .none
                
            case .importWallet:
                return .none
            }
        }
    }
}

extension OnboardingFlowReducer.State {
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

// MARK: - ViewStore

extension OnboardingFlowViewStore {
    func bindingForDestination(_ destination: OnboardingFlowReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}
