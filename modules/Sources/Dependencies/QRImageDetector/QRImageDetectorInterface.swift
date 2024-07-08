//
//  QRImageDetectorInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-04-18.
//

import SwiftUI
import ComposableArchitecture

extension DependencyValues {
    public var qrImageDetector: QRImageDetectorClient {
        get { self[QRImageDetectorClient.self] }
        set { self[QRImageDetectorClient.self] = newValue }
    }
}

@DependencyClient
public struct QRImageDetectorClient {
    public var check: @Sendable (UIImage?) -> [String]?
}
