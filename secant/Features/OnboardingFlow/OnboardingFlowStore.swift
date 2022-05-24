//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture

typealias OnboardingFlowReducer = Reducer<OnboardingFlowState, OnboardingFlowAction, OnboardingFlowEnvironment>
typealias OnboardingFlowStore = Store<OnboardingFlowState, OnboardingFlowAction>
typealias OnboardingFlowViewStore = ViewStore<OnboardingFlowState, OnboardingFlowAction>

// MARK: - State

struct OnboardingFlowState: Equatable {
    enum Route: Equatable, CaseIterable {
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
    var route: Route?

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
    var importWalletState: ImportWalletState
}

extension OnboardingFlowState {
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

// MARK: - Action

enum OnboardingFlowAction: Equatable {
    case next
    case back
    case skip
    case updateRoute(OnboardingFlowState.Route?)
    case createNewWallet
    case importExistingWallet
    case importWallet(ImportWalletAction)
}

// MARK: - Environment

struct OnboardingFlowEnvironment {
    let mnemonic: WrappedMnemonic
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension OnboardingFlowEnvironment {
    static let live = OnboardingFlowEnvironment(
        mnemonic: .live,
        walletStorage: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let demo = OnboardingFlowEnvironment(
        mnemonic: .mock,
        walletStorage: .live(),
        zcashSDKEnvironment: .testnet
    )
}

// MARK: - Reducer

extension OnboardingFlowReducer {
    static let `default` = OnboardingFlowReducer.combine(
        [
            onboardingReducer,
            importWalletReducer
        ]
    )

    private static let onboardingReducer = OnboardingFlowReducer { state, action, _ in
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
            
        case .updateRoute(let route):
            state.route = route
            return .none

        case .createNewWallet:
            state.route = .createNewWallet
            return .none

        case .importExistingWallet:
            state.route = .importExistingWallet
            return .none
            
        case .importWallet(let route):
            return .none
        }
    }
    
    private static let importWalletReducer: OnboardingFlowReducer = ImportWalletReducer.default.pullback(
        state: \OnboardingFlowState.importWalletState,
        action: /OnboardingFlowAction.importWallet,
        environment: { environment in
            ImportWalletEnvironment(
                mnemonic: environment.mnemonic,
                walletStorage: environment.walletStorage,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )
}

// MARK: - ViewStore

extension OnboardingFlowViewStore {
    func bindingForRoute(_ route: OnboardingFlowState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}
