//
//  MessageShape.swift
//
//
//  Created by Lukáš Korba on 25.10.2023.
//

import SwiftUI
import Generated

struct MessageShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            path.addLine(to: CGPoint(x: 15, y: rect.height))
            path.addLine(to: CGPoint(x: 15, y: rect.height + 7))
            path.addLine(to: CGPoint(x: 35, y: rect.height))

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
        }
    }
}

struct MessageShapeModifier: ViewModifier {
    let filled: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if filled {
                    MessageShape()
                        .foregroundColor(Asset.Colors.suppressed72.color)
                    MessageShape()
                        .stroke()
                } else {
                    MessageShape()
                        .stroke()
                }
            }
    }
}

extension View {
    public func messageShape(filled: Bool = false) -> some View {
        modifier(MessageShapeModifier(filled: filled))
    }
}

#Preview {
    Text("some message")
        .frame(width: 320, height: 145)
        .messageShape(filled: true)
}
