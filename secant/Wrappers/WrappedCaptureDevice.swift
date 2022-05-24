//
//  WrappedCaptureDevice.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 17.05.2022.
//

import Foundation
import AVFoundation

struct WrappedCaptureDevice {
    enum WrappedCaptureDeviceError: Error {
        case captureDeviceFailed
        case lockFailed
        case torchUnavailable
    }
    
    let isTorchAvailable: () throws -> Bool
    let torch: (Bool) throws -> Void
}

extension WrappedCaptureDevice {
    static let real = WrappedCaptureDevice(
        isTorchAvailable: {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                throw WrappedCaptureDeviceError.captureDeviceFailed
            }

            return videoCaptureDevice.hasTorch
        },
        torch: { isTorchOn in
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                throw WrappedCaptureDeviceError.captureDeviceFailed
            }
            
            guard videoCaptureDevice.hasTorch else {
                throw WrappedCaptureDeviceError.torchUnavailable
            }

            do {
                try videoCaptureDevice.lockForConfiguration()
                videoCaptureDevice.torchMode = isTorchOn ? .on : .off
                videoCaptureDevice.unlockForConfiguration()
            } catch {
                throw WrappedCaptureDeviceError.lockFailed
            }
        }
    )
    
    static let none = WrappedCaptureDevice(
        isTorchAvailable: { false },
        torch: { _ in }
    )
}
