//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI

@main
struct SecantApp: App {
    var homeStore: HomeStore = .placeholder
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(store: homeStore)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
