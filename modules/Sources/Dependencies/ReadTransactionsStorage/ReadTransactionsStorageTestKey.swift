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
        markIdAsRead: XCTUnimplemented("\(Self.self).markIdAsRead"),
        readIds: XCTUnimplemented("\(Self.self).readIds", placeholder: [:]),
        availabilityTimestamp: XCTUnimplemented("\(Self.self).availabilityTimestamp", placeholder: 0)
    )
}

extension ReadTransactionsStorageClient {
    public static let noOp = Self(
        markIdAsRead: { _ in },
        readIds: { [:] },
        availabilityTimestamp: { 0 }
    )
}
