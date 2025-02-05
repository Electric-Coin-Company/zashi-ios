//
//  KeystoneHandlerLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-20.
//

import ComposableArchitecture
import KeystoneSDK

class KeystoneSDKWrapper {
    let keystoneSDK = KeystoneSDK()
    var foundResult = false
    
    func decodeQR(_ qrCode: String) -> DecodeResult? {
        guard !foundResult else { return nil }
        
        let result = try? keystoneSDK.decodeQR(qrCode: qrCode)
        
        foundResult = result?.progress == 100
        
        return result
    }
    
    func resetQRDecoder() {
        foundResult = false
        keystoneSDK.resetQRDecoder()
    }
}

extension KeystoneHandlerClient: DependencyKey {
    public static var liveValue: Self {
        let wrapper = KeystoneSDKWrapper()

        return .init(
            decodeQR: { wrapper.decodeQR($0) },
            resetQRDecoder: { wrapper.resetQRDecoder() }
        )
    }
}
