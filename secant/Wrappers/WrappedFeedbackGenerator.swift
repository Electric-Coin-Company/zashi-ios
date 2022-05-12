//
//  WrappedFeedbackGenerator.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import UIKit

struct WrappedFeedbackGenerator {
    let generateFeedback: () -> Void
}

extension WrappedFeedbackGenerator {
    static let haptic = WrappedFeedbackGenerator(
        generateFeedback: { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    )
    
    static let silent = WrappedFeedbackGenerator(
        generateFeedback: { }
    )
}
