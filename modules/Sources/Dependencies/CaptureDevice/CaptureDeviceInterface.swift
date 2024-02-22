//
//  CaptureDeviceInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    public var captureDevice: CaptureDeviceClient {
        get { self[CaptureDeviceClient.self] }
        set { self[CaptureDeviceClient.self] = newValue }
    }
}

public struct CaptureDeviceClient {
    public enum CaptureDeviceClientError: Error {
        case authorizationStatus
        case captureDevice
        case lockForConfiguration
        case torchUnavailable
    }

    public let isAuthorized: () -> Bool
    public let isTorchAvailable: () -> Bool
    public let torch: (Bool) throws -> Void
}
