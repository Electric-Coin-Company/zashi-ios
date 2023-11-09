//
//  MessageShape.swift
//
//
//  Created by Lukáš Korba on 25.10.2023.
//

import SwiftUI
import Generated

public struct MessageShape: Shape {
    public enum Orientation: Sendable {
        case left
        case right
    }
    
    let orientation: MessageShape.Orientation
    
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            if orientation == .left {
                path.addLine(to: CGPoint(x: 15, y: rect.height))
                path.addLine(to: CGPoint(x: 15, y: rect.height + 7))
                path.addLine(to: CGPoint(x: 35, y: rect.height))
            } else {
                path.addLine(to: CGPoint(x: rect.width - 35, y: rect.height))
                path.addLine(to: CGPoint(x: rect.width - 15, y: rect.height + 7))
                path.addLine(to: CGPoint(x: rect.width - 15, y: rect.height))
            }

            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
        }
    }
}

public struct MessageShapeModifier: ViewModifier {
    let filled: Color?
    let orientation: MessageShape.Orientation
    
    public func body(content: Content) -> some View {
        content
            .background {
                if let filled {
                    MessageShape(orientation: orientation)
                        .foregroundColor(filled)
                }
            }
            .overlay {
                MessageShape(orientation: orientation)
                    .stroke()
            }
    }
}

extension View {
    public func messageShape(
        filled: Color? = nil,
        orientation: MessageShape.Orientation = .left
    ) -> some View {
        modifier(
            MessageShapeModifier(
                filled: filled,
                orientation: orientation
            )
        )
    }
}

#Preview {
    VStack {
        Text("some message")
            .padding(5)
            .messageShape(
                filled: Asset.Colors.messageBcgReceived.color,
                orientation: .right
            )
            .padding(.bottom, 20)

        Text("some message")
            .padding(5)
            .messageShape()
            .padding(.bottom, 20)
        
        Text("some message")
            .frame(width: 320, height: 145)
            .messageShape(filled: Asset.Colors.shade72.color)
    }
}
