//
//  AudioServicesInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import AVFoundation

extension DependencyValues {
    var audioServices: AudioServicesClient {
        get { self[AudioServicesClient.self] }
        set { self[AudioServicesClient.self] = newValue }
    }
}

struct AudioServicesClient {
    let systemSoundVibrate: () -> Void
}
