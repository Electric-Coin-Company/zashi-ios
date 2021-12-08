//
//  DesignGuide.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
// swiftlint:disable line_length

import SwiftUI

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

            CircularFrame()
                .frame(width: 300, height: 300, alignment: .center)

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
                    Button("Back") { dump("Example button") }
                        .navigationButtonStyle
                        .frame(width: 80, height: 40)

                    Button("Skip") { dump("Example button") }
                        .navigationButtonStyle
                        .frame(width: 80, height: 40)

                    // TODO: Change state to selected
                    Button("Back") { dump("Example button") }
                        .navigationButtonStyle
                        .frame(width: 80, height: 40)

                    // TODO: Change state to selected
                    Button("Skip") { dump("Example button") }
                        .navigationButtonStyle
                        .frame(width: 80, height: 40)
                }
            }

            VStack {
                Text("Recovery Phrase Chip")
                    .font(.caption)

                EnumeratedChip(index: 1, text: "Salami")
                    .frame(width: 100, height: 40)

                EmptyChip()
                    .frame(width: 100, height: 40)
            }

            VStack(spacing: 25) {
                Asset.Assets.Icons.shield.image
                    .frame(width: 76, height: 76)

                Asset.Assets.Icons.profile.image
                    .frame(width: 76, height: 76)

                Asset.Assets.Icons.list.image
                    .frame(width: 76, height: 76)
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
            .primaryButtonStyle
            .frame(height: buttonHeight)

            // TODO: Pressed Primary Button
            Button(action: {}) {
                Text("Pressed Primary Button")
            }
            .primaryButtonStyle
            .frame(height: buttonHeight)

            // Disabled Primary Button
            Button(action: {}) {
                Text("Disabled Primary Button")
            }
            .primaryButtonStyle
            .frame(height: buttonHeight)
            .disabled(true)

            // Active Button
            Button(action: {}) {
                Text("Active Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)

            // TODO: Pressed Active Button
            Button(action: {}) {
                Text("Pressed Active Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)

            // TODO: Disabled Active Button
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
            .secondaryButtonStyle
            .frame(height: buttonHeight)

            // Disabled Secondary Button
            Button(action: {}) {
                Text("Disabled Secondary Button")
            }
            .secondaryButtonStyle
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
                .preferredColorScheme(.dark)

            DesignGuide()
                .applyScreenBackground()
                .preferredColorScheme(.light)
        }
        .previewLayout(.fixed(width: 1086, height: 1080))
    }
}
