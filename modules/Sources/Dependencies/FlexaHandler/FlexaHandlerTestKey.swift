//
//  FlexaHandlerTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-09-2024
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension FlexaHandlerClient: TestDependencyKey {
    public static let testValue = Self(
        prepare: XCTUnimplemented("\(Self.self).prepare"),
        open: XCTUnimplemented("\(Self.self).open"),
        onTransactionRequest: XCTUnimplemented("\(Self.self).onTransactionRequest", placeholder: Empty().eraseToAnyPublisher()),
        transactionSent: XCTUnimplemented("\(Self.self).transactionSent"),
        updateBalance: XCTUnimplemented("\(Self.self).updateBalance")
    )
}

extension FlexaHandlerClient {
    public static let noOp = Self(
        prepare: { },
        open: { },
        onTransactionRequest: { Empty().eraseToAnyPublisher() },
        transactionSent: { _, _ in },
        updateBalance: { _ in }
    )
}
