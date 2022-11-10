//
//  AudioServicesTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension AudioServicesClient: TestDependencyKey {
    static let testValue = Self(
        systemSoundVibrate: XCTUnimplemented("\(Self.self).systemSoundVibrate")
    )
}
