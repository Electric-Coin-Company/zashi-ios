//
//  DesignGuide.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.

import SwiftUI
import Generated
import UIComponents
import OnboardingFlow

struct DesignGuide: View {
    let columns = [GridItem(.adaptive(minimum: 320, maximum: .infinity))]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                TextAndPlaceholdersGuide()
                SmallVisualElements()
                ButtonGuide()
            }
        }
        .padding(30)
        .navigationBarHidden(true)
    }
}

// swiftlint:disable line_length
struct TextAndPlaceholdersGuide: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("H1 Onboarding Rubik Light")
                .font(FontFamily.Rubik.light.textStyle(.title))
                .foregroundColor(Asset.Colors.Text.titleText.color)

            Text(
                """
                Rubik 16 regular #93A4BE Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd
                """
            )
            .font(FontFamily.Rubik.light.textStyle(.footnote))
            .fontWeight(.thin)
            .foregroundColor(Asset.Colors.Text.titleText.color)

            Text("Placeholder for rectangular view")
                .frame(width: 386, height: 125, alignment: .center)

            ProgressView.init(value: 25.0, total: 100.0)
                .onboardingProgressStyle
        }
    }
}

struct SmallVisualElements: View {
    let gridItems = [GridItem(.flexible(minimum: 40, maximum: 100)), GridItem(.flexible(minimum: 40, maximum: 100))]

    var body: some View {
        VStack(spacing: 75) {
            VStack {
                Text("Navigation Buttons")
                    .font(.caption)

                LazyVGrid(columns: gridItems) {
                    Button(L10n.General.back) { dump("Example button") }
                        .activeButtonStyle
                        .frame(width: 80, height: 40)

                    Button(L10n.General.skip) { dump("Example button") }
                        .activeButtonStyle
                        .frame(width: 80, height: 40)

                    // TODO: [#696] Change state to selected https://github.com/zcash/ZcashLightClientKit/issues/696
                    Button(L10n.General.back) { dump("Example button") }
                        .activeButtonStyle
                        .frame(width: 80, height: 40)

                    // TODO: [#696] Change state to selected https://github.com/zcash/ZcashLightClientKit/issues/696
                    Button(L10n.General.skip) { dump("Example button") }
                        .activeButtonStyle
                        .frame(width: 80, height: 40)
                }
            }

            VStack {
                Text("Recovery Phrase Chip")
                    .font(.caption)

                EnumeratedChip(index: 1, text: "Salami".redacted)
                    .frame(width: 100, height: 40)

                EmptyChip()
                    .frame(width: 100, height: 40)
            }
        }
    }
}

struct ButtonGuide: View {
    let buttonHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 30) {
            // Primary Button
            Button(action: {}) {
                Text("Primary Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)

            // Pressed Primary Button
            Button(action: {}) {
                Text("Pressed Primary Button")
            }
            .primaryButtonPressedStyle
            .frame(height: buttonHeight)

            // Disabled Primary Button
            Button(action: {}) {
                Text("Disabled Primary Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)
            .disabled(true)

            // Active Button
            Button(action: {}) {
                Text("Active Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)

            // Pressed Active Button
            Button(action: {}) {
                Text("Pressed Active Button")
            }
            .activeButtonPressedStyle
            .frame(height: buttonHeight)

            // Disabled Active Button
            Button(action: {}) {
                Text("Disabled Active Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)
            .disabled(true)

            // Secondary Button
            Button(action: {}) {
                Text("Secondary Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)

            // Disabled Secondary Button
            Button(action: {}) {
                Text("Disabled Secondary Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)
            .disabled(true)

            Spacer()
        }
    }
}

struct DesignGuide_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DesignGuide()
                .applyScreenBackground()
                .preferredColorScheme(.light)
        }
        .previewLayout(.fixed(width: 1086, height: 1080))
    }
}

// MARK: - Pressed Simulated

extension Button {
    var primaryButtonPressedStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.button.color,
                background: Asset.Colors.Buttons.primaryButtonPressed.color,
                pressedBackgroundColor: Asset.Colors.Buttons.primaryButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.primaryButtonDisabled.color
            )
        )
    }
    
    var activeButtonPressedStyle: some View {
        buttonStyle(
            StandardButtonStyle(
                foregroundColor: Asset.Colors.Text.activeButtonText.color,
                background: Asset.Colors.Buttons.activeButtonPressed.color,
                pressedBackgroundColor: Asset.Colors.Buttons.activeButtonPressed.color,
                disabledBackgroundColor: Asset.Colors.Buttons.activeButtonDisabled.color
            )
        )
    }
}
