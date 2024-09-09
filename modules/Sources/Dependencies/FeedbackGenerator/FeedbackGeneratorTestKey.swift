//
//  FeedbackGeneratorTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension FeedbackGeneratorClient: TestDependencyKey {
    public static let testValue = Self(
        generateSuccessFeedback: unimplemented("\(Self.self).generateSuccessFeedback"),
        generateWarningFeedback: unimplemented("\(Self.self).generateWarningFeedback"),
        generateErrorFeedback: unimplemented("\(Self.self).generateErrorFeedback")
    )
}

extension FeedbackGeneratorClient {
    public static let noOp = Self(
        generateSuccessFeedback: { },
        generateWarningFeedback: { },
        generateErrorFeedback: { }
    )
}
