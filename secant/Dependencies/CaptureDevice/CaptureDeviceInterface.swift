//
//  CaptureDeviceInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    var captureDevice: CaptureDeviceClient {
        get { self[CaptureDeviceClient.self] }
        set { self[CaptureDeviceClient.self] = newValue }
    }
}

struct CaptureDeviceClient {
    enum CaptureDeviceClientError: Error {
        case captureDeviceFailed
        case lockFailed
        case torchUnavailable
    }
    
    let isTorchAvailable: () throws -> Bool
    let torch: (Bool) throws -> Void
}
