//
//  ZcashBadge.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import SwiftUI
import Generated

struct ZcashBadge: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                let outterPadding = proxy.size.height * 0.015
                let firstPadding = proxy.size.height * 0.075 + outterPadding
                let secondRingPadding = firstPadding * 1.5
                let outerShadowDrop = proxy.size.height * 0.14
                let outerShadowOffset = proxy.size.height * 0.055

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Asset.Colors.ZcashBadge.outerRingGradientStart.color,
                                Asset.Colors.ZcashBadge.outerRingGradientEnd.color
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .if(colorScheme == .light) { view in
                        view.shadow(
                            color: Asset.Colors.ZcashBadge.shadowColor.color,
                            radius: outerShadowDrop,
                            x: outerShadowOffset,
                            y: outerShadowOffset
                        )
                    }

                Circle()
                    .foregroundColor(Asset.Colors.ZcashBadge.thickRing.color)
                    .padding(outterPadding)

                Circle()
                    .foregroundColor(Asset.Colors.ZcashBadge.thinRing.color)
                    .padding(firstPadding)

                Circle()
                    .foregroundColor(Asset.Colors.ZcashBadge.innerCircle.color)
                    .padding(secondRingPadding)

                ZcashSymbol()
                    .fill(Asset.Colors.ZcashBadge.zcashLogoFill.color)
                    .padding(firstPadding + secondRingPadding)
            }
        }
    }
}
