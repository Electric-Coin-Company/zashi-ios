//
//  CrashReporterLiveKey.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/2/23.
//

import ComposableArchitecture
import Foundation
import Firebase
import FirebaseCrashlytics

extension CrashReporterClient: DependencyKey {
    public static let liveValue = CrashReporterClient(
        configure: { canConfigure in
            let fileName = "GoogleService-Info.plist"

            // checks whether the crash reporter's config file is a dummy_file purposely placed by the build job or the real one.
            // this does not check the integrity of the Plist file for Firebase.
            // that's a problem for the library itself.
            guard
                let configFile = Bundle.main.url(forResource: fileName, withExtension: nil),
                let properties = NSDictionary(contentsOf: configFile),
                properties["IS_DUMMY_FILE"] == nil,
                canConfigure
            else {
                return
            }

            FirebaseApp.configure()
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        },
        testCrash: {
            fatalError("Crash was triggered to test the crash reporter")
        },
        optIn: {
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        },
        optOut: {
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        }
    )
}
