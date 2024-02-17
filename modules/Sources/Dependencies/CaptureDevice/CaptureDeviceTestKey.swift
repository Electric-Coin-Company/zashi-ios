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
        isAuthorized: XCTUnimplemented("\(Self.self).isAuthorized", placeholder: false),
        isTorchAvailable: XCTUnimplemented("\(Self.self).isTorchAvailable", placeholder: false),
        torch: XCTUnimplemented("\(Self.self).torch")
    )
}

extension CaptureDeviceClient {
    public static let noOp = Self(
        isAuthorized: { false },
        isTorchAvailable: { false },
        torch: { _ in }
    )
}
