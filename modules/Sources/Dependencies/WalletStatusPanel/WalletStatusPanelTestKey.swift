//
//  WalletStatusPanelTestKey.swift
//  
//
//  Created by Lukáš Korba on 19.12.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension WalletStatusPanelClient: TestDependencyKey {
    public static let testValue = Self(
        value: XCTUnimplemented("\(Self.self).value", placeholder: .init(.none)),
        updateValue: XCTUnimplemented("\(Self.self).updateValue")
    )
}

extension WalletStatusPanelClient {
    public static let noOp = Self(
        value: { .init(.none) },
        updateValue: { _ in }
    )
}
