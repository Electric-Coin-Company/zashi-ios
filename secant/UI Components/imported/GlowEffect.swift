//
//  GlowEffect.swift
//  Zircles
//
//  Created by Francisco Gindre on 6/19/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI

typealias GlowVibe = GlowEffect.Vibe
typealias GlowSoul = GlowEffect.Soul

struct GlowEffect: ViewModifier {
    enum Vibe {
        case mild
        case cool
        case heavy
    }
    
    enum Soul {
        case solid(color: Color)
        case split(left: Color, right: Color)
    }
    
    var vibe: Vibe
    
    var soul: Soul
    
    func body(content: Content) -> some View {
        let colors = color(soul: soul)

        return content
            .shadow(color:colors.0.opacity(0.7), radius: radius(vibe), x: -offsetX(vibe), y: 0)
            .shadow(color:colors.1.opacity(0.7), radius: radius(vibe), x: offsetX(vibe), y: 0)

    }

    func color(soul: Soul) -> (Color, Color) {
        switch soul {
        case .solid(let color):
            return (color,color)
        case .split(let left,let right):
            return (left, right)
        }
    }
    
    func radius(_ vibe: Vibe) -> CGFloat {
        switch vibe {
        case .mild:
            return 6
        case .cool:
            return 20
        case .heavy:
            return 40
        }
    }
    
    func offsetX(_ vibe: Vibe) -> CGFloat {
        switch vibe {
        case .mild:
            return 3
        case .cool:
            return 12
        case .heavy:
            return 24
        }
    }
}

extension View {
    func glow(vibe: GlowVibe, soul: GlowSoul) -> some View {
        self.modifier(
            GlowEffect(vibe: vibe, soul: soul)
        )
    }
}
