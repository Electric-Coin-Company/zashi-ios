//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 1/6/22.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct WelcomeView: View {
    var store: WelcomeStore
    
    public init(store: WelcomeStore) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 80) {
            VStack {
                Image(Asset.Assets.welcomeScreenLogo.name)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding(.top, 100)
                
                Spacer()
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
