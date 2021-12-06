//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI

@main
struct SecantApp: App {
    var homeStore: HomeStore = .demo
    var recoveryPhraseStore: RecoveryPhraseDisplayStore = .demo
    var body: some Scene {
        WindowGroup {
            NavigationView {
//                HomeView(store: homeStore)
                RecoveryPhraseDisplayView(store: recoveryPhraseStore)
            }
            .navigationViewStyle(StackNavigationViewStyle()) 
        }
    }
}
