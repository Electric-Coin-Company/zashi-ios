//
//  CaptureDeviceTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension CaptureDeviceClient: TestDependencyKey {
    public static let testValue = Self(
        isAuthorized: unimplemented("\(Self.self).isAuthorized", placeholder: false),
        isTorchAvailable: unimplemented("\(Self.self).isTorchAvailable", placeholder: false),
        torch: unimplemented("\(Self.self).torch", placeholder: {}())
    )
}

extension CaptureDeviceClient {
    public static let noOp = Self(
        isAuthorized: { false },
        isTorchAvailable: { false },
        torch: { _ in }
    )
}
