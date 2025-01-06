//
//  ScreenBackground.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI
import Generated

public struct ScreenBackgroundModifier: ViewModifier {
    var color: Color

    public func body(content: Content) -> some View {
        ZStack {
            color
                .edgesIgnoringSafeArea(.all)

            content
        }
    }
}

struct ScreenGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    let stops: [Gradient.Stop]

    var body: some View {
        LinearGradient(
            stops: stops,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct ScreenGradientBackgroundModifier: ViewModifier {
    let stops: [Gradient.Stop]

    func body(content: Content) -> some View {
        ZStack {
            ScreenGradientBackground(stops: stops)
                .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

struct ScreenOnboardingGradientBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            if colorScheme == .light {
                ScreenGradientBackground(
                    stops: [
                        Gradient.Stop(color: Asset.Colors.ZDesign.Base.concrete.color, location: 0.0),
                        Gradient.Stop(color: Asset.Colors.ZDesign.Base.bone.color, location: 1.0)
                    ]
                )
                .edgesIgnoringSafeArea(.all)
            } else {
                ScreenGradientBackground(
                    stops: [
                        Gradient.Stop(color: Asset.Colors.ZDesign.sharkShades06dp.color, location: 0.0),
                        Gradient.Stop(color: Asset.Colors.ZDesign.Base.obsidian.color, location: 1.0)
                    ]
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            content
        }
    }
}

extension View {
    public func applyScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                color: Asset.Colors.background.color
            )
        )
    }
    
    public func applyErredScreenBackground() -> some View {
        @Environment(\.colorScheme) var colorScheme

        return self.modifier(
            ScreenGradientBackgroundModifier(
                stops: [
                    Gradient.Stop(color: Design.Utility.WarningYellow._100.color(colorScheme), location: 0.0),
                    Gradient.Stop(color: Design.screenBackground.color(colorScheme), location: 0.4)
                ]
            )
        )
    }
    
    public func applyBrandedScreenBackground() -> some View {
        @Environment(\.colorScheme) var colorScheme

        return self.modifier(
            ScreenGradientBackgroundModifier(
                stops: [
                    Gradient.Stop(color: Design.Utility.Brand._600.color(colorScheme), location: 0.0),
                    Gradient.Stop(color: Design.Utility.Brand._400.color(colorScheme), location: 0.5),
                    Gradient.Stop(color: Design.screenBackground.color(colorScheme), location: 0.75)
                ]
            )
        )
    }
    
    public func applyOnboardingScreenBackground() -> some View {
        self.modifier(
            ScreenOnboardingGradientBackgroundModifier()
        )
    }
    
    public func applySuccessScreenBackground() -> some View {
        @Environment(\.colorScheme) var colorScheme

        return self.modifier(
            ScreenGradientBackgroundModifier(
                stops: [
                    Gradient.Stop(color: Design.Utility.SuccessGreen._100.color(colorScheme), location: 0.0),
                    Gradient.Stop(color: Design.screenBackground.color(colorScheme), location: 0.4)
                ]
            )
        )
    }
    
    public func applyFailureScreenBackground() -> some View {
        @Environment(\.colorScheme) var colorScheme

        return self.modifier(
            ScreenGradientBackgroundModifier(
                stops: [
                    Gradient.Stop(color: Design.Utility.ErrorRed._100.color(colorScheme), location: 0.0),
                    Gradient.Stop(color: Design.screenBackground.color(colorScheme), location: 0.4)
                ]
            )
        )
    }
}

struct ScreenBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
        .applyScreenBackground()
        .preferredColorScheme(.light)
    }
}
