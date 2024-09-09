//
//  AutolockHandlerTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-10-2024.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

extension AutolockHandlerClient: TestDependencyKey {
    public static let testValue = Self(
        value: unimplemented("\(Self.self).value", placeholder: {}()),
        batteryStatePublisher: unimplemented(
            "\(Self.self).batteryStatePublisher",
            placeholder: NotificationCenter.Publisher(center: .default, name: Notification.Name(rawValue: "placeholder"))
        )
    )
}

extension AutolockHandlerClient {
    public static let noOp = Self(
        value: { _ in },
        batteryStatePublisher: { NotificationCenter.Publisher(center: .default, name: Notification.Name(rawValue: "noOp")) }
    )
}
