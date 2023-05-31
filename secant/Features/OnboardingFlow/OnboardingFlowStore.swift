//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Generated
import Models

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
            let title: String
            let description: String
            let background: Image
        }

        var destination: Destination?
        var walletConfig: WalletConfig
        var importWalletState: ImportWalletReducer.State
        var index = 0
        var skippedAtindex: Int?
        var steps: IdentifiedArrayOf<Step> = Self.onboardingSteps

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

    enum Action: Equatable {
        case back
        case createNewWallet
        case importExistingWallet
        case importWallet(ImportWalletReducer.Action)
        case next
        case onAppear
        case skip
        case updateDestination(OnboardingFlowReducer.State.Destination?)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.importWalletState, action: /Action.importWallet) {
            ImportWalletReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.walletConfig.isEnabled(.onboardingFlow) {
                    return EffectTask(value: .skip)
                }
                return .none
                
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
                title: L10n.Onboarding.Step1.title,
                description: L10n.Onboarding.Step1.description,
                background: Asset.Assets.Backgrounds.callout1.image
            ),
            Step(
                id: UUID(),
                title: L10n.Onboarding.Step2.title,
                description: L10n.Onboarding.Step2.description,
                background: Asset.Assets.Backgrounds.callout2.image
            ),
            Step(
                id: UUID(),
                title: L10n.Onboarding.Step3.title,
                description: L10n.Onboarding.Step3.description,
                background: Asset.Assets.Backgrounds.callout3.image
            ),
            Step(
                id: UUID(),
                title: L10n.Onboarding.Step4.title,
                description: L10n.Onboarding.Step4.description,
                background: Asset.Assets.Backgrounds.callout4.image
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
