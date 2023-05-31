//
//  WalletConfigProviderTestKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine
import Models

extension WalletConfigProviderClient: TestDependencyKey {
    public static let testValue = Self(
        load: XCTUnimplemented("\(Self.self).load", placeholder: Just(WalletConfig.default).eraseToAnyPublisher()),
        update: XCTUnimplemented("\(Self.self).update")
    )
}

extension WalletConfigProviderClient {
    public static let noOp = Self(
        load: { Just(WalletConfig.default).eraseToAnyPublisher() },
        update: { _, _ in Just(Void()).eraseToAnyPublisher() }
    )
}
