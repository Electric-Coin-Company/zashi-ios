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
        load: unimplemented("\(Self.self).load", placeholder: Just(WalletConfig.initial).eraseToAnyPublisher()),
        update: unimplemented("\(Self.self).update", placeholder: Just({}()).eraseToAnyPublisher())
    )
}

extension WalletConfigProviderClient {
    public static let noOp = Self(
        load: { Just(WalletConfig.initial).eraseToAnyPublisher() },
        update: { _, _ in Just(Void()).eraseToAnyPublisher() }
    )
}
