//
//  WalletConfigProviderTestKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension WalletConfigProviderClient: TestDependencyKey {
    static let testValue = Self(
        load: XCTUnimplemented("\(Self.self).load", placeholder: Just(WalletConfig.default).eraseToAnyPublisher()),
        update: XCTUnimplemented("\(Self.self).update")
    )
}

extension WalletConfigProviderClient {
    static let noOp = Self(
        load: { Just(WalletConfig.default).eraseToAnyPublisher() },
        update: { _, _ in Just(Void()).eraseToAnyPublisher() }
    )
}
