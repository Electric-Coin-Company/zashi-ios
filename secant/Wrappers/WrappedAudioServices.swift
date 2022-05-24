//
//  WrappedAudioServices.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 19.05.2022.
//

import Foundation
import AVFoundation

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
