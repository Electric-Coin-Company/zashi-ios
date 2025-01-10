//
//  KeystoneHandlerLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-20.
//

import ComposableArchitecture
import KeystoneSDK

extension KeystoneHandlerClient: DependencyKey {
    public static var liveValue: Self {
        let keystoneSDK = KeystoneSDK()

        return .init(
            decodeQR: {
                try? keystoneSDK.decodeQR(qrCode: $0)
            },
            resetQRDecoder: {
                keystoneSDK.resetQRDecoder()
            }
        )
    }
}
