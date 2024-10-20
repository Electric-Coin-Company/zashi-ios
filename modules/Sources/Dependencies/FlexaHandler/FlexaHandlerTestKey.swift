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
        prepare: unimplemented("\(Self.self).prepare"),
        open: unimplemented("\(Self.self).open"),
        onTransactionRequest: unimplemented("\(Self.self).onTransactionRequest", placeholder: Empty().eraseToAnyPublisher()),
        clearTransactionRequest: unimplemented("\(Self.self).clearTransactionRequest"),
        transactionSent: unimplemented("\(Self.self).transactionSent"),
        updateBalance: unimplemented("\(Self.self).updateBalance"),
        flexaAlert: unimplemented("\(Self.self).flexaAlert")
    )
}

extension FlexaHandlerClient {
    public static let noOp = Self(
        prepare: { },
        open: { },
        onTransactionRequest: { Empty().eraseToAnyPublisher() },
        clearTransactionRequest: { },
        transactionSent: { _, _ in },
        updateBalance: { _, _ in },
        flexaAlert: { _, _ in }
    )
}
