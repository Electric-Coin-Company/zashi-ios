//
//  FeedbackGeneratorKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02.11.2022.
//

import ComposableArchitecture

private enum FeedbackGeneratorKey: DependencyKey {
    static let liveValue = WrappedFeedbackGenerator.haptic
    static let testValue = WrappedFeedbackGenerator.silent
}

extension DependencyValues {
    var feedbackGenerator: WrappedFeedbackGenerator {
        get { self[FeedbackGeneratorKey.self] }
        set { self[FeedbackGeneratorKey.self] = newValue }
    }
}
