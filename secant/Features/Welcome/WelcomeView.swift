//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 1/6/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

struct WelcomeView: View {
    var store: WelcomeStore
        
    var body: some View {
        VStack(alignment: .center, spacing: 80) {
            VStack {
                Image(Asset.Assets.welcomeScreenLogo.name)
                    .resizable()
                    .frame(width: 210, height: 210)
                    .padding(.bottom, 14)
                
                Text(L10n.WelcomeScreen.title)
                    .font(.system(size: 23))
            }
            .accessDebugMenuWithHiddenGesture {
                ViewStore(store).send(.debugMenuStartup)
            }
        }
        .frame(alignment: .center)
        .applyScreenBackground()
        .animation(.easeInOut, value: 3)
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
            .preferredColorScheme(.light)

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
                .preferredColorScheme(.light)

            WelcomeView(store: .demo)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
