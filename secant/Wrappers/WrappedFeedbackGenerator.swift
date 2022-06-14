//
//  WrappedFeedbackGenerator.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import UIKit

struct WrappedFeedbackGenerator {
    let generateSuccessFeedback: () -> Void
    let generateWarningFeedback: () -> Void
    let generateErrorFeedback: () -> Void
}

extension WrappedFeedbackGenerator {
    static let haptic = WrappedFeedbackGenerator(
        generateSuccessFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.success) },
        generateWarningFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.warning) },
        generateErrorFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    )
    
    static let silent = WrappedFeedbackGenerator(
        generateSuccessFeedback: { },
        generateWarningFeedback: { },
        generateErrorFeedback: { }
    )
}
