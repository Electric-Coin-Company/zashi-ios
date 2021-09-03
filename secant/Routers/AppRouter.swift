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
        Text("Create New")
    }

    @ViewBuilder func home() -> some View {
        Text("Home Screen")
    }

    @ViewBuilder func loadingScreen() -> some View {
        LoadingScreen(router: self, viewModel: LoadingScreenViewModel(services: self.services))
    }
    
    @ViewBuilder func loadingFailedScreen() -> some View {
        Text("loading failed")
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
        }
    }
}

extension AppRouter: LoadingScreenRouter {
    func proceedToWelcome() {
        self.screen = .createRestoreWallet
    }

    func proceedToHome() {
        self.screen = .home
    }
    
    // TODO: handle Errors
    func failWithError() {
        self.screen = .loadingFailed
    }
}
