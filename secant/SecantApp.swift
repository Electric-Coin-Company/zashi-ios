//
//  secantApp.swift
//  secant
//
//  Created by Francisco Gindre on 7/29/21.
//

import SwiftUI

@main
struct SecantApp: App {
    
    @StateObject var appRouter = AppRouter(services: MockServices())
    var body: some Scene {
        WindowGroup {
            appRouter.rootView()
        }
    }
}
