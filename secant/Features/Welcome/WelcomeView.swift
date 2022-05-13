//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 1/6/22.
//

import SwiftUI
import ComposableArchitecture

struct WelcomeView: View {
    var store: WelcomeStore
        
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 80) {
                    let diameter = proxy.size.width - 40
                    ZcashBadge()
                        .frame(
                            width: diameter,
                            height: diameter
                        )
                        .accessDebugMenuWithHiddenGesture {
                            ViewStore(store).send(.debugMenuStartup)
                        }

                    VStack {
                        Text("welcomeScreen.title")
                            .titleText()

                        Text("welcomeScreen.subtitle")
                            .captionText()
                    }
                }
            }
            .frame(alignment: .center)
            .applyScreenBackground()
            .animation(.easeInOut, value: 3)
        }
    }
}

// MARK: - Previews

struct WelcomeView_Previews: PreviewProvider {
    static let squarePreviewSize: CGFloat = 360

    static var previews: some View {
        ZcashBadge()
            .applyScreenBackground()
            .previewLayout(
                .fixed(
                    width: squarePreviewSize,
                    height: squarePreviewSize
                )
            )
            .preferredColorScheme(.dark)

        ZStack {
            ZcashBadge()
        }
        .padding()
        .applyScreenBackground()
        .previewLayout(
            .fixed(
                width: squarePreviewSize,
                height: squarePreviewSize
            )
        )
        .preferredColorScheme(.light)

        Group {
            WelcomeView(store: .demo)
                .preferredColorScheme(.dark)

            WelcomeView(store: .demo)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
