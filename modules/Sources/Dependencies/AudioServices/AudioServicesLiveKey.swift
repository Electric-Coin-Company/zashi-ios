//
//  AudioServicesLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import AVFoundation
import ComposableArchitecture

extension AudioServicesClient: DependencyKey {
    public static let liveValue = Self(
        systemSoundVibrate: { AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) }
    )
}
