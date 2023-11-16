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
import NumberFormatter

public struct WelcomeView: View {
    var store: WelcomeStore
    
    public init(store: WelcomeStore) {
        self.store = store
    }

    public var body: some View {
        GeometryReader { proxy in
            WithViewStore(store, observe: { $0 }) { viewStore in
                Asset.Assets.zashiLogo.image
                    .resizable()
                    .frame(width: 249, height: 321)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.5
                    )
                
                Asset.Assets.splashHi.image
                    .resizable()
                    .frame(width: 246, height: 213)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.8
                    )
                    .accessDebugMenuWithHiddenGesture {
                        viewStore.send(.debugMenuStartup)
                    }
            }
        }
        .background(Asset.Colors.splash.color)
        .ignoresSafeArea()
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
