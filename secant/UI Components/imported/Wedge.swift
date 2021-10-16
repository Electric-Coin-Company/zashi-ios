//
//  Wedge.swift
//  Zircles
//
//  Created by Francisco Gindre on 6/19/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import Foundation
import SwiftUI

struct Ring: Shape {
    
    private var wedge: Wedge = Wedge(
        startAngle: Angle(radians: 0),
        endAngle: Angle(radians: 2 * Double.pi),
                                clockwise: false
                                )
    
    func path(in rect: CGRect) -> Path {
        self.wedge.path(in: rect)
    }
}

struct Wedge: Shape {
    
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = true
    
    func path(in rect: CGRect) -> Path {
        Path() { path in
             path.addArc(
                           center: CGPoint(
                                x: rect.midX,
                                y: rect.midY
                            ),
                           radius: rect.width / 2 ,
                           startAngle: startAngle,
                           endAngle: endAngle,
                           clockwise: clockwise
                       )
        }
    }
}
