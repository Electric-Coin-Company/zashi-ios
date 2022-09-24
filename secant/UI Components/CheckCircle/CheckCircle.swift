//
//  ZcashCheckCircle.swift
//  wallet
//
//  Created by Francisco Gindre on 1/7/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct CheckCircle: View {
    let viewStore: CheckCircleViewStore

    var externalRingColor: Color = Asset.Colors.CheckCircle.externalRing.color
    var internalRingColor: Color = Asset.Colors.CheckCircle.internalRing.color

    var backgroundColor: Color = .clear

    func backgroundShape(size: CGSize) -> some View {
        Path { path in
            path.addArc(
                center: CGPoint(
                    x: size.width / 2,
                    y: size.height / 2
                ),
                radius: size.width / 2,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 360),
                clockwise: true
            )
        }
        .fill(self.backgroundColor)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.backgroundShape(size: geometry.size)
                self.ring(size: geometry.size, color: self.externalRingColor, lineWidth: 2)
                self.ring(
                    size: CGSize(width: geometry.size.width, height: geometry.size.height),
                    color: self.internalRingColor,
                    lineWidth: 4
                )
                .scaleEffect(0.9, anchor: UnitPoint(x: 0.5, y: 0.5))
                .opacity(self.viewStore.state ? 1 : 0)

                Image("checkmark")
                    .opacity(self.viewStore.state ? 1 : 0)
            }
            .gesture(
                TapGesture()
                    .onEnded { _ in self.viewStore.send(.updateIsChecked) }
            )
        }
        .frame(width: 30, height: 30, alignment: .center)
    }

    func ringPath(size: CGSize) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(
                    x: size.width / 2,
                    y: size.height / 2
                ),
                radius: size.width / 2,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 360),
                clockwise: true
            )
        }
    }

    func ring(size: CGSize, color: Color, lineWidth: CGFloat) -> some View {
        ringPath(size: size)
            .stroke(color, lineWidth: lineWidth)
    }
}

struct ZcashCheckCircle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CheckCircle(viewStore: ViewStore(CheckCircleStore.mock(isChecked: true)))
            CheckCircle(viewStore: ViewStore(CheckCircleStore.mock(isChecked: false)))
            Spacer()
        }
        .applyDarkScreenBackground()
    }
}
