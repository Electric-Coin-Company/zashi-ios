//
//  TooltipShape.swift
//  
//
//  Created by Lukáš Korba on 23.11.2023.
//

import SwiftUI
import Generated

public struct TooltipShape: Shape {
    public func path(in rect: CGRect) -> Path {
        let arrowXRatio = CGFloat(0.6)
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width * arrowXRatio, y: 0))

            path.addLine(to: CGPoint(x: rect.width * arrowXRatio + 10, y: -10))
            path.addLine(to: CGPoint(x: rect.width * arrowXRatio + 20, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            path.closeSubpath()
        }
    }
}

public struct TooltipShapeModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background {
                TooltipShape()
                    .foregroundColor(Asset.Colors.secondary.color)
            }
            .overlay {
                TooltipShape()
                    .stroke()
            }
    }
}

extension View {
    public func tooltipShape() -> some View {
        modifier(
            TooltipShapeModifier()
        )
    }
}
