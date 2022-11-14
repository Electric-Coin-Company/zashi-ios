//
//  LocalAuthenticationLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import LocalAuthentication

extension LocalAuthenticationClient: DependencyKey {
    static let liveValue = Self(
        authenticate: {
            let context = LAContext()
            var error: NSError?
            let reason = "The Following content requires authentication."
            
            do {
                /// Biometrics validation
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                } else {
                    /// Biometrics not supported by the device, fallback to passcode
                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
                    } else {
                        /// No local authentication available, user's device is not protected, fallback to allow access to sensetive content
                        return true
                    }
                }
            } catch {
                /// Some interuption occured during the authentication, access to the sensitive content is therefore forbiden
                return false
            }
        }
    )
}
