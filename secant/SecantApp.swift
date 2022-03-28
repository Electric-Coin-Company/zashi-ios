//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
    var appStore: AppStore = .placeholder
    lazy var appViewStore = ViewStore(
        appStore.scope(state: { _ in () }),
        removeDuplicates: ==
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appViewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

@main
struct SecantApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: appDelegate.appStore)
        }
    }
}
