//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture

typealias OnboardingViewStore = ViewStore<OnboardingState, OnboardingAction>

struct OnboardingState: Equatable {
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

extension OnboardingViewStore {
    func bindingForRoute(_ route: OnboardingState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

enum OnboardingAction: Equatable {
    case next
    case back
    case skip
    case updateRoute(OnboardingState.Route?)
    case createNewWallet
    case importExistingWallet
    case importWallet(ImportWalletAction)
}

struct OnboardingEnvironment {
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let walletStorage: WalletStorageInteractor
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension OnboardingEnvironment {
    static let live = OnboardingEnvironment(
        mnemonicSeedPhraseProvider: .live,
        walletStorage: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let demo = OnboardingEnvironment(
        mnemonicSeedPhraseProvider: .mock,
        walletStorage: .live(),
        zcashSDKEnvironment: .testnet
    )
}

typealias OnboardingReducer = Reducer<OnboardingState, OnboardingAction, OnboardingEnvironment>

extension OnboardingReducer {
    static let `default` = OnboardingReducer.combine(
        [
            onboardingReducer,
            importWalletReducer
        ]
    )

    private static let onboardingReducer = OnboardingReducer { state, action, _ in
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
    
    private static let importWalletReducer: OnboardingReducer = ImportWalletReducer.default.pullback(
        state: \OnboardingState.importWalletState,
        action: /OnboardingAction.importWallet,
        environment: { environment in
            ImportWalletEnvironment(
                mnemonicSeedPhraseProvider: environment.mnemonicSeedPhraseProvider,
                walletStorage: environment.walletStorage,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )
}
