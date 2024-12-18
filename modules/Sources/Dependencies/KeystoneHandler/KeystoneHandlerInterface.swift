//
//  KeystoneHandlerInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-20.
//

import ComposableArchitecture
import KeystoneSDK

extension DependencyValues {
    public var keystoneHandler: KeystoneHandlerClient {
        get { self[KeystoneHandlerClient.self] }
        set { self[KeystoneHandlerClient.self] = newValue }
    }
}

@DependencyClient
public struct KeystoneHandlerClient {
    public var decodeQR: @Sendable (String) -> DecodeResult?
    public var resetQRDecoder: @Sendable () -> Void
}
