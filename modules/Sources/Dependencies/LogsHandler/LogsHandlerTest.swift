//
//  LogsHandlerTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension LogsHandlerClient: TestDependencyKey {
    public static let testValue = Self(
        exportAndStoreLogs: XCTUnimplemented("\(Self.self).exportAndStoreLogs", placeholder: nil)
    )
}

extension LogsHandlerClient {
    public static let noOp = Self(
        exportAndStoreLogs: { _, _, _ in nil }
    )
}
