//
//  Stepper.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 9/22/21.
//

import Foundation
import SwiftUI

/// This will be replaced by the real thing
struct Stepper: View {
    var currentStep: Int
    var totalSteps: Int

    var body: some View {
        Text("Step \(currentStep + 1) of \(totalSteps)")
    }
}
