//
//  WrappedAudioServices.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 19.05.2022.
//

import Foundation
import AVFoundation
import ComposableArchitecture

struct WrappedAudioServices {
    let systemSoundVibrate: () -> Void
}

extension WrappedAudioServices {
    static let haptic = WrappedAudioServices(
        systemSoundVibrate: { AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) }
    )
    
    static let silent = WrappedAudioServices(
        systemSoundVibrate: { }
    )
}

private enum AudioServicesKey: DependencyKey {
    static let liveValue = WrappedAudioServices.haptic
    static let testValue = WrappedAudioServices.silent
}

extension DependencyValues {
    var audioServices: WrappedAudioServices {
        get { self[AudioServicesKey.self] }
        set { self[AudioServicesKey.self] = newValue }
    }
}
