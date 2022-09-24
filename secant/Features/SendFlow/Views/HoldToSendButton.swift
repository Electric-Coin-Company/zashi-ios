//
//  ZcashSendButton.swift
//  wallet
//
//  Created by Francisco Gindre on 1/9/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct HoldToSendButton: View {
    var minimumDuration: TimeInterval = 5
    let innerCircleScale: CGFloat = 0.8
    var completionStrokeWidth: CGFloat = 16.0
    @State var isPressing = false
    @State var startAngle: CGFloat = -90
    @State var endAngle: CGFloat = -90

    var longPressSucceded: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            GeometryReader { geometry in
                Circle()
                    .size(geometry.size)
                    .fill(Color.black)
                    .shadow(color: Asset.Colors.Shadow.holdToSendButtonShadow.color, radius: 2, x: 0, y: 2)

                Circle()
                    .size(geometry.size)
                    .fill(Asset.Colors.Shadow.holdToSendButtonShadow.color)
                    .scaleEffect(self.innerCircleScale)
                    .opacity(0.35)

                Wedge(
                    startAngle: self.startAngle,
                    endAngle: self.endAngle,
                    clockwise: false
                )
                .stroke(Asset.Colors.ProgressIndicator.holdToSendButton.color, lineWidth: self.completionStrokeWidth)
                .frame(
                    width: geometry.size.width - self.completionStrokeWidth,
                    height: geometry.size.height - self.completionStrokeWidth
                )
                .offset(x: self.completionStrokeWidth / 2, y: self.completionStrokeWidth / 2)

                Text("Press and hold\nto send ZEC")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(
                        minWidth: geometry.size.width,
                        idealWidth: geometry.size.width,
                        maxWidth: geometry.size.width,
                        minHeight: geometry.size.height,
                        idealHeight: geometry.size.height,
                        maxHeight: geometry.size.height,
                        alignment: .center
                    )
            }
        }
        .frame(
            width: 167,
            height: 167,
            alignment: .center
        )
        .onLongPressGesture(
            minimumDuration: minimumDuration,
            maximumDistance: 167,
            pressing: { isPressing in
                if !self.isPressing && isPressing {
                    self.isPressing = isPressing
                    withAnimation(.linear(duration: self.minimumDuration)) {
                        self.startAnimation()
                    }
                } else if self.isPressing && !isPressing {
                    self.isPressing = isPressing
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.cancelAnimation()
                    }
                }
            },
            perform: {
                self.endAnimation()
                self.isPressing = false
                longPressSucceded()
            }
        )
    }

    func startAnimation() {
        self.startAngle = -90
        self.endAngle = 270
    }

    func endAnimation() {
        self.startAngle = -90
        self.endAngle = 270
    }

    func cancelAnimation() {
        self.startAngle = -90
        self.endAngle = -90
    }
}

struct HoldToSendButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HoldToSendButton(longPressSucceded: { })
                .applyDarkScreenBackground()
        }
    }
}
