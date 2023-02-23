//
//  WalletConfigProviderTestKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

extension WalletConfigProviderClient: TestDependencyKey {
    static let testValue = Self(
        load: XCTUnimplemented("\(Self.self).load", placeholder: WalletConfig.default)
    )
}

extension WalletConfigProviderClient {
    static let `default` = Self(
        load: { WalletConfig.default }
    )
}
