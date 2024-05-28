//
//  AddressBookTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension AddressBookClient: TestDependencyKey {
    public static let testValue = Self(
        all: XCTUnimplemented("\(Self.self).all"),
        deleteRecipient: XCTUnimplemented("\(Self.self).deleteRecipient"),
        name: XCTUnimplemented("\(Self.self).name", placeholder: nil),
        recipientExists: XCTUnimplemented("\(Self.self).recipientExists", placeholder: false),
        storeRecipient: XCTUnimplemented("\(Self.self).storeRecipient")
    )
}

extension AddressBookClient {
    public static let noOp = Self(
        all: { [] },
        deleteRecipient: { _ in },
        name: { _ in nil },
        recipientExists: { _ in false },
        storeRecipient: { _ in }
    )
}
