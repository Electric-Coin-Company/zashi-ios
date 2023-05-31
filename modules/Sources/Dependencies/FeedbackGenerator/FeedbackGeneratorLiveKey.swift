//
//  FeedbackGeneratorLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import UIKit
import ComposableArchitecture

extension FeedbackGeneratorClient: DependencyKey {
    public static let liveValue = Self(
        generateSuccessFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.success) },
        generateWarningFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.warning) },
        generateErrorFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    )
}
