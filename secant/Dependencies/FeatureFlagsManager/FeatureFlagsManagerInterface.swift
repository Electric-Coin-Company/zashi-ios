//
//  FeatureFlagsManagerInterface.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var featureFlagsManager: FeatureFlagsManagerClient {
        get { self[FeatureFlagsManagerClient.self] }
        set { self[FeatureFlagsManagerClient.self] = newValue }
    }
}

struct FeatureFlagsManagerClient {
    let load: () async -> FeatureFlagsConfiguration
}
