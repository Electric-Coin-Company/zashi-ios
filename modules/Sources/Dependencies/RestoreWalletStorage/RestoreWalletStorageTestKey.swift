//
//  RestoreWalletStorageTestKey.swift
//  
//
//  Created by Lukáš Korba on 19.12.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension RestoreWalletStorageClient: TestDependencyKey {
    public static let testValue = Self(
        value: XCTUnimplemented("\(Self.self).value", placeholder: .placeholder),
        updateValue: XCTUnimplemented("\(Self.self).updateValue")
    )
}

extension RestoreWalletStorageClient {
    public static let noOp = Self(
        value: { .placeholder },
        updateValue: { _ in }
    )
}
