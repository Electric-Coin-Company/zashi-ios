//
//  FeedbackGenerator.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/23/2022.
//

import UIKit

protocol FeedbackGenerator {
    func generateFeedback()
}

/// use in case of testing or when real haptic feedback is not appropriate
class SilentFeedbackGenerator: FeedbackGenerator {
    func generateFeedback() { }
}

/// haptic feedback for the failures (when we want to amplify importance of the failure)
class ImpactFeedbackGenerator: FeedbackGenerator {
    let generator = UINotificationFeedbackGenerator()
    
    func generateFeedback() {
        generator.notificationOccurred(.error)
    }
}
