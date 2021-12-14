//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI

@main
struct SecantApp: App {
    var appStore: AppStore = .placeholder

    var body: some Scene {
        WindowGroup {
            AppView(store: appStore)
        }
    }
}

extension AppStore {
    static var placeholder: AppStore {
        AppStore(
            initialState: .placeholder,
            reducer: .default,
            environment: .init()
        )
    }
}
