//
//  CaptureDeviceKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.11.2022.
//

import ComposableArchitecture

private enum CaptureDeviceKey: DependencyKey {
    static let liveValue = WrappedCaptureDevice.real
    static let testValue = WrappedCaptureDevice.none
}

extension DependencyValues {
    var captureDevice: WrappedCaptureDevice {
        get { self[CaptureDeviceKey.self] }
        set { self[CaptureDeviceKey.self] = newValue }
    }
}
