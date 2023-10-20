//
//  ZashiButton.swift
//
//
//  Created by Lukáš Korba on 28.09.2023.
//

import SwiftUI
import Generated

public struct ZcashButtonStyle: ButtonStyle {
    public enum Appearance {
        case primary
        case secondary
    }

    let isEnabled: Bool
    let appearance: Appearance
    @State private var offset = 0.0
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            Rectangle()
                .frame(height: 60)
                .foregroundColor(
                    appearance == .primary ? .clear
                    : isEnabled ? Asset.Colors.primary.color : Asset.Colors.suppressed72.color
                )
                .border(isEnabled ? Asset.Colors.primary.color : Asset.Colors.suppressed72.color)
                .offset(CGSize(width: 10, height: 10))

            Rectangle()
                .frame(height: 60)
                .foregroundColor(
                    appearance == .primary ?
                    isEnabled ? Asset.Colors.primary.color : Asset.Colors.suppressed72.color
                    : Asset.Colors.secondary.color
                )
                .border(Asset.Colors.primary.color)
                .overlay(content: {
                    configuration.label
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(
                            appearance == .primary ? Asset.Colors.secondary.color
                            : isEnabled ? Asset.Colors.primary.color : Asset.Colors.suppressed72.color
                        )
                })
                .offset(CGSize(width: offset, height: offset))
        }
        .onChange(of: configuration.isPressed) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.05)) { offset = 10.0 }
                withAnimation(.easeInOut(duration: 0.05).delay(0.05)) { offset = 0.0 }
            }
        }
    }
}

struct ZcashButtonModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled

    let appearance: ZcashButtonStyle.Appearance
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(ZcashButtonStyle(isEnabled: isEnabled, appearance: appearance))
            .frame(minWidth: 236)
    }
}

extension Button {
    public func zcashStyle(_ appearance: ZcashButtonStyle.Appearance = .primary) -> some View {
        modifier(ZcashButtonModifier(appearance: appearance))
    }
}

#Preview {
    VStack {
        Button { } label: {
            Text("PRIMARY".uppercased())
        }
        .zcashStyle()
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(false)

        Button { } label: {
            Text("PRIMARY DISABLED".uppercased())
        }
        .zcashStyle()
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(true)

        Button { } label: {
            Text("SECONDARY".uppercased())
        }
        .zcashStyle(.secondary)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(false)

        Button { } label: {
            Text("SECONDARY DISABLED".uppercased())
        }
        .zcashStyle(.secondary)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(true)
    }
}
