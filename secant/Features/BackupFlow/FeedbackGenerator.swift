//
//  FeedbackGenerator.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/23/2022.
//

import UIKit

struct FeedbackGenerator {
    let generateFeedback: () -> Void
}

extension FeedbackGenerator {
    static let haptic = FeedbackGenerator(
        generateFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    )
    
    static let silent = FeedbackGenerator(
        generateFeedback: { }
    )
}
