//
//  ZashiButton.swift
//
//
//  Created by Lukáš Korba on 28.09.2023.
//

import SwiftUI
import Generated

public struct ZcashButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
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
            // shadow
            Rectangle()
                .fill(shadowFillColor())
                .frame(height: height)
                .border(shadowBorderColor())
                .offset(CGSize(width: shadowOffset, height: shadowOffset))

            // button
            Rectangle()
                .fill(buttonFillColor())
                .frame(height: height)
                .border(buttonBorderColor())
                .overlay(content: {
                    configuration.label
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(fontColor())
                })
                .offset(CGSize(width: offset, height: offset))
        }
        .onChange(of: configuration.isPressed) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.05)) {
                    offset = shadowOffset
                }
                withAnimation(.easeInOut(duration: 0.05).delay(0.05)) {
                    offset = 0.0
                }
            }
        }
    }

    private func fontColor() -> Color {
        if colorScheme == .light {
            if !isEnabled {
                return Asset.Colors.btnLabelShade.color
            } else {
                return appearance == .primary
                ? Asset.Colors.btnSecondary.color
                : Asset.Colors.btnPrimary.color
            }
        } else {
            if !isEnabled && appearance == .secondary {
                return Asset.Colors.btnLightShade.color
            } else {
                return Asset.Colors.btnSecondary.color
            }
        }
    }

    private func buttonFillColor() -> Color {
        if colorScheme == .light {
            if appearance == .secondary {
                return Asset.Colors.btnSecondary.color
            } else {
                return isEnabled
                ? Asset.Colors.btnPrimary.color
                : Asset.Colors.btnLightShade.color
            }
        } else {
            if isEnabled {
                return Asset.Colors.btnPrimary.color
            } else {
                return appearance == .primary
                ? Asset.Colors.btnDarkShade.color
                : Asset.Colors.btnSecondary.color
            }
        }
    }
    
    private func buttonBorderColor() -> Color {
        if colorScheme == .light {
            return Asset.Colors.btnPrimary.color
        } else {
            if !isEnabled && appearance == .secondary {
                return Asset.Colors.btnPrimary.color
            } else {
                return Asset.Colors.btnSecondary.color
            }
        }
    }
    
    private func shadowFillColor() -> Color {
        if colorScheme == .light {
            if isEnabled && appearance == .secondary {
                return Asset.Colors.btnPrimary.color
            } else {
                return Asset.Colors.btnSecondary.color
            }
        } else {
            if appearance == .primary {
                return Asset.Colors.btnPrimary.color
            } else {
                return isEnabled
                ? Asset.Colors.btnDarkShade.color
                : Asset.Colors.btnSecondary.color
            }
        }
    }
    
    private func shadowBorderColor() -> Color {
        if colorScheme == .light {
            if isEnabled && appearance == .secondary {
                return Asset.Colors.btnSecondary.color
            } else {
                return Asset.Colors.btnPrimary.color
            }
        } else {
            if !isEnabled && appearance == .secondary {
                return Asset.Colors.btnPrimary.color
            } else {
                return Asset.Colors.btnSecondary.color
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
            Text("SECONDARY".uppercased())
        }
        .zcashStyle(.secondary)
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
            Text("SECONDARY DISABLED".uppercased())
        }
        .zcashStyle(.secondary)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(true)
    }
    .padding()
    .background(.blue)
    .preferredColorScheme(.light)
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
            Text("SECONDARY".uppercased())
        }
        .zcashStyle(.secondary)
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
            Text("SECONDARY DISABLED".uppercased())
        }
        .zcashStyle(.secondary)
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .disabled(true)
    }
    .padding()
    .background(.blue)
    .preferredColorScheme(.dark)
}
