//
//  AppRouterRouter.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation
import SwiftUI

enum AppRouterScreen {
    case appLoading
    case createRestoreWallet
    case home
    case loadingFailed
    case onboarding
}

class AppRouter: Router {
    @Published var screen: AppRouterScreen = .appLoading

    var services: Services

    init(services: Services) {
        self.services = services
    }

    @ViewBuilder func rootView() -> some View {
        // Add your content here
        NavigationView {
            AppRouterView(router: self)
        }
    }

    @ViewBuilder func createNew() -> some View {
        WelcomeScreen(
            viewModel: WelcomeScreenViewModel(services: self.services),
            router: nil
        )
    }

    @ViewBuilder func home() -> some View {
        Text("Home Screen")
    }

    @ViewBuilder func loadingScreen() -> some View {
        LoadingScreen(
            viewModel: LoadingScreenViewModel(services: self.services),
            router: self
        )
    }
    
    @ViewBuilder func loadingFailedScreen() -> some View {
        Text("loading failed")
    }

    @ViewBuilder func onboarding() -> some View {
        OnboardingScreen(
            viewModel: OnboardingScreenViewModel(
                services:
                    OnboardingStepProvider(
                        steps: [
                            .stepZero,
                            .stepOne
                        ],
                        startingAt: 0
                    )
            ),
            router: self
        )
    }
}

struct AppRouterView: View {
    @StateObject var router: AppRouter

    var body: some View {
        viewForScreen(router.screen)
    }

    @ViewBuilder func viewForScreen(_ screen: AppRouterScreen) -> some View {
        switch router.screen {
        case .appLoading:           router.loadingScreen()
        case .createRestoreWallet:  router.createNew()
        case .home:                 router.home()
        case .loadingFailed:        router.loadingFailedScreen()
        case .onboarding:           router.onboarding()
        }
    }
}

extension AppRouter: LoadingScreenRouter {
    func proceedToWelcome() {
        self.screen = .onboarding
    }

    func proceedToHome() {
        self.screen = .home
    }
    
    // TODO: handle Errors
    func failWithError() {
        self.screen = .loadingFailed
    }
}

extension AppRouter: OnboardingScreenRouter {
    func onboardingDone() {
        self.screen = .createRestoreWallet
    }
}
