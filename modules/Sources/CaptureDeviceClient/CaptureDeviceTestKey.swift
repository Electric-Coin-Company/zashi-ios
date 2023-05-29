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
        isTorchAvailable: XCTUnimplemented("\(Self.self).isTorchAvailable", placeholder: false),
        torch: XCTUnimplemented("\(Self.self).torch")
    )
}

extension CaptureDeviceClient {
    public static let noOp = Self(
        isTorchAvailable: { false },
        torch: { _ in }
    )
}
