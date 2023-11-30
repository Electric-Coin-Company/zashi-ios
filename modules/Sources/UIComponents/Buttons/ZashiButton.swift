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
    let height: CGFloat
    let shadowOffset: CGFloat
    @State private var offset = 0.0
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            Rectangle()
                .fill(
                    appearance == .primary ? .white
                    : isEnabled ? Asset.Colors.primary.color : Asset.Colors.shade72.color
                )
                .frame(height: height)
                .border(isEnabled ? Asset.Colors.primary.color : Asset.Colors.shade72.color)
                .offset(CGSize(width: shadowOffset, height: shadowOffset))

            Rectangle()
                .frame(height: height)
                .foregroundColor(
                    appearance == .primary ?
                    isEnabled ? Asset.Colors.primary.color : Asset.Colors.shade72.color
                    : Asset.Colors.secondary.color
                )
                .border(Asset.Colors.primary.color)
                .overlay(content: {
                    configuration.label
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(
                            appearance == .primary ? Asset.Colors.secondary.color
                            : isEnabled ? Asset.Colors.primary.color : Asset.Colors.shade72.color
                        )
                })
                .offset(CGSize(width: offset, height: offset))
        }
        .onChange(of: configuration.isPressed) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.05)) { offset = shadowOffset }
                withAnimation(.easeInOut(duration: 0.05).delay(0.05)) { offset = 0.0 }
            }
        }
    }
}

struct ZcashButtonModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled

    let appearance: ZcashButtonStyle.Appearance
    let minWidth: CGFloat?
    let height: CGFloat
    let shadowOffset: CGFloat

    func body(content: Content) -> some View {
        if let minWidth {
            content
                .buttonStyle(
                    ZcashButtonStyle(
                        isEnabled: isEnabled,
                        appearance: appearance,
                        height: height,
                        shadowOffset: shadowOffset
                    )
                )
                .frame(minWidth: minWidth)
        } else {
            content
                .buttonStyle(
                    ZcashButtonStyle(
                        isEnabled: isEnabled,
                        appearance: appearance,
                        height: height,
                        shadowOffset: shadowOffset
                    )
                )
        }
    }
}

extension Button {
    public func zcashStyle(
        _ appearance: ZcashButtonStyle.Appearance = .primary,
        minWidth: CGFloat? = 236,
        height: CGFloat = 60,
        shadowOffset: CGFloat = 10
    ) -> some View {
        modifier(
            ZcashButtonModifier(
                appearance: appearance,
                minWidth: minWidth,
                height: height,
                shadowOffset: shadowOffset
            )
        )
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
