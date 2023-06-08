//
//  Button+Disabling.swift
//  secant
//
//  Created by Francisco Gindre on 3/13/23.
//

import SwiftUI

extension View {
    public func disable(when isDisabled: Bool, dimmingOpacity: Double) -> some View {
        self.modifier(
            DisableWithOpacity(isDisabled: isDisabled, opacity: dimmingOpacity)
        )
    }
}

struct DisableWithOpacity: ViewModifier {
    var isDisabled: Bool
    var opacity: Double

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
            .opacity(isDisabled ? opacity : 1.0)
    }
}
