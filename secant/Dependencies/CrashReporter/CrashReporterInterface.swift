//
//  CrashReporterInterface.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var crashReporter: CrashReporterClient {
        get { self[CrashReporterClient.self] }
        set { self[CrashReporterClient.self] = newValue }
    }
}

struct CrashReporterClient {
    /// Configures the crash reporter if possible.
    /// if it can't be configured this will fail silently
    var configure: (Bool) -> Void

    /// this will test the crash reporter
    /// - Note: depending of the crash reporter this may or may not crash your app.
    var testCrash: () -> Void

    /// this will tell the crash reporter that the user a has decided to opt-in crash reporting
    var optIn: () -> Void

    /// this will tell the crash reporter that the user has decided to opt-out of crash reporting
    var optOut: () -> Void
}
