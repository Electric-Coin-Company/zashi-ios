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

            Text("Placeholder for circular view")
                .frame(width: 370, height: 370, alignment: .center)

            Text("Placeholder for rectangular view")
                .frame(width: 386, height: 125, alignment: .center)
            OnboardingProgressViewPreviewHelper()
        }
    }
}

struct SmallVisualElements: View {
    let gridItems = [GridItem(.flexible(minimum: 40, maximum: 100)), GridItem(.flexible(minimum: 40, maximum: 100))]

    var body: some View {
        VStack {
            Text("Navigation Buttons")
                .font(.caption)
            LazyVGrid(columns: gridItems) {
                // TODO: Change state to selected
                Button("Back") { dump("Example button") }
                    .buttonStyle(NavigationButtonStyle())
                    .frame(width: 80, height: 40)
                Button("Skip") { dump("Example button") }
                .buttonStyle(NavigationButtonStyle())
                    .frame(width: 80, height: 40)

                Button("Back") { dump("Example button") }
                    .buttonStyle(NavigationButtonStyle())
                    .frame(width: 80, height: 40)
                Button("Skip") { dump("Example button") }
                .buttonStyle(NavigationButtonStyle())
                    .frame(width: 80, height: 40)
            }

            Text("Recovery Phrase Chip")
                .font(.caption)
            EnumeratedChip(index: 1, text: "Salami")
                .frame(width: 100, height: 40)
            EmptyChip()
                .frame(width: 100, height: 40)
            Text("shield icon")
                .frame(width: 76, height: 76)
            Text("profile icon")
                .frame(width: 76, height: 76)
            Text("listing icon")
                .frame(width: 76, height: 76)
        }
    }
}

struct ButtonGuide: View {
    let buttonHeight: CGFloat = 60

    var body: some View {
        VStack(spacing: 30) {
            // Idle Primary Button
            Button(action: {}) {
                Text("Primary Button")
            }
            .primaryButtonStyle
            .frame(height: buttonHeight)

            // TODO: Pressed Primary Button
            Button(action: {}) {
                Text("Primary Button")
            }
            .primaryButtonStyle
            .frame(height: buttonHeight)

            // Disabled Primary Button
            Button(action: {}) {
                Text("Primary Button")
            }
            .primaryButtonStyle
            .frame(height: buttonHeight)
            .disabled(true)

            // Idle Primary Action Button
            Button(action: {}) {
                Text("Primary Active Button")
            }
            .createButtonStyle
            .frame(height: buttonHeight)

            // TODO: Pressed Primary Action Button
            Button(action: {}) {
                Text("Primary Active Button")
            }
            .createButtonStyle
            .frame(height: buttonHeight)

            // TODO: Pressed Primary Action Button
            Button(action: {}) {
                Text("Primary Active Button")
            }
            .createButtonStyle
            .frame(height: buttonHeight)

            // Idle Secondary Button
            Button(action: {}) {
                Text("Secondary Button")
            }
            .secondaryButtonStyle
            .frame(height: buttonHeight)

            // Action Button
            Button(action: {}) {
                Text("Action Button")
            }
            .activeButtonStyle
            .frame(height: buttonHeight)
            Spacer()
        }
    }
}

struct DesignGuide_Previews: PreviewProvider {
    static var previews: some View {
        DesignGuide()
            .applyScreenBackground()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 420, height: 1080))

        DesignGuide()
            .applyScreenBackground()
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 1086, height: 1080))
    }
}
