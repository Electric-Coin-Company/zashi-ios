//
//  SupportDataGeneratorInterface.swift
//  secant
//
//  Created by Michal Fousek on 28.02.2023.
//

import ComposableArchitecture

extension DependencyValues {
    public var supportDataGenerator: SupportDataGeneratorClient {
        get { self[SupportDataGeneratorClient.self] }
        set { self[SupportDataGeneratorClient.self] = newValue }
    }
}

public struct SupportDataGeneratorClient {
    public let generate: () -> SupportData
}
