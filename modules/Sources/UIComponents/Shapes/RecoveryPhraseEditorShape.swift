//
//  RecoveryPhraseEditorShape.swift
//
//
//  Created by Lukáš Korba on 30.10.2023.
//

import SwiftUI
import Generated

struct RecoveryPhraseEditorShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
        }
    }
}

struct RecoveryPhraseEditorModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay {
                RecoveryPhraseEditorShape()
                    .stroke()
            }
    }
}

extension View {
    public func recoveryPhraseShape() -> some View {
        modifier(RecoveryPhraseEditorModifier())
    }
}

#Preview {
    Text("some message")
        .frame(width: 320, height: 145)
        .recoveryPhraseShape()
}
