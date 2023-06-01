//
//  Wedge.swift
//  secant-testnet
//
//  Created by Michal Fousek on 24.09.2022.
//

import SwiftUI

public struct Wedge: Shape {
    var startAngle: CGFloat
    var endAngle: CGFloat
    var clockwise = true

    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(startAngle, endAngle) }
        set {
            startAngle = newValue.first
            endAngle = newValue.second
        }
    }

    public func path(in rect: CGRect) -> Path {
        let callback: (inout Path) -> Void = { path in
            path.addArc(
                center: CGPoint(
                    x: rect.midX,
                    y: rect.midY
                ),
                radius: rect.width / 2,
                startAngle: Angle(degrees: Double(startAngle)),
                endAngle: Angle(degrees: Double(endAngle)),
                clockwise: clockwise
            )
        }

        return Path(callback)
    }
}
