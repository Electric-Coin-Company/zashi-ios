//
//  AudioServicesInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import AVFoundation

extension DependencyValues {
    public var audioServices: AudioServicesClient {
        get { self[AudioServicesClient.self] }
        set { self[AudioServicesClient.self] = newValue }
    }
}

@DependencyClient
public struct AudioServicesClient {
    public let systemSoundVibrate: () -> Void
    
    public init(systemSoundVibrate: @escaping () -> Void) {
        self.systemSoundVibrate = systemSoundVibrate
    }
}
