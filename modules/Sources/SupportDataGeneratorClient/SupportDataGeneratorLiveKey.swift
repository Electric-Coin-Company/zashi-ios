//
//  SupportDataGeneratorLiveKey.swift
//  secant
//
//  Created by Michal Fousek on 28.02.2023.
//

import ComposableArchitecture

extension SupportDataGeneratorClient: DependencyKey {
    public static let liveValue = Self(
        generate: { SupportDataGenerator.generate() }
    )
}
