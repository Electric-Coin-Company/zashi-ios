//
//  ReadTransactionsStorageTestKey.swift
//  
//
//  Created by Lukáš Korba on 11.11.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension ReadTransactionsStorageClient: TestDependencyKey {
    public static let testValue = Self(
        markIdAsRead: unimplemented("\(Self.self).markIdAsRead", placeholder: {}()),
        readIds: unimplemented("\(Self.self).readIds", placeholder: [:]),
        availabilityTimestamp: unimplemented("\(Self.self).availabilityTimestamp", placeholder: 0),
        resetZashi: unimplemented("\(Self.self).resetZashi", placeholder: {}())
    )
}

extension ReadTransactionsStorageClient {
    public static let noOp = Self(
        markIdAsRead: { _ in },
        readIds: { [:] },
        availabilityTimestamp: { 0 },
        resetZashi: { }
    )
}
