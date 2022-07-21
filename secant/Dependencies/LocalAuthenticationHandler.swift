//
//  LocalAuthenticationHandler.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 20.07.2022.
//

import Foundation
import LocalAuthentication
import ComposableArchitecture
import Combine

struct LocalAuthenticationHandler {
    let authenticate: () -> Effect<Result<Bool, Never>, Never>
}

/// The `Result` of live implementation of `LocalAuthentication` has been purposely simplified to Never fails (never returns a .failure)
/// Instead, we care only about `Bool` result of authentication.
extension LocalAuthenticationHandler {
    enum LocalAuthenticationNotAvailable: Error {}
    
    static let live = LocalAuthenticationHandler {
        Deferred {
            Future { promise in
                let context = LAContext()
                var error: NSError?
                let reason = "Folowing content requires authentication."

                /// Biometrics validation
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                        promise(.success(success))
                    }
                } else {
                    /// Biometrics not supported by the device, fallback to passcode
                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                            promise(.success(success))
                        }
                    } else {
                        /// No local authentication available, user's device is not protected, fallback to allow access to sensetive content
                        promise(.success(true))
                    }
                }
            }
        }
        .catchToEffect()
    }
    
    static let unimplemented = LocalAuthenticationHandler(
        authenticate: { Effect(value: Result.success(false)) }
    )
}
