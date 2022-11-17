//
//  NotificationCenterTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension NotificationCenterClient: TestDependencyKey {
    static let testValue = Self(
        publisherFor: XCTUnimplemented("\(Self.self).publisherFor", placeholder: nil)
    )
}

extension NotificationCenterClient {
    static let noOp = NotificationCenterClient(
        publisherFor: { _ in nil }
    )
}
