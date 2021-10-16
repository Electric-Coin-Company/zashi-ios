//
//  Wedge_Preview.swift
//  Zircles
//
//  Created by Francisco Gindre on 6/19/20.
//  Copyright © 2020 Electric Coin Company. All rights reserved.
//

import SwiftUI
struct ZircleProgress: View {
    var progress: Double = 0
    var stroke: StrokeStyle
    var body: some View {
        Wedge(startAngle: Angle(radians: 0),
              endAngle: Angle(radians: 2 * Double.pi * progress),
              clockwise: false)
            .stroke(style: stroke)
            .fill(LinearGradient.zButtonGradient)
            .rotationEffect(Angle(radians: -Double.pi / 2))
    }
}

struct Wedge_Previews: PreviewProvider {
    @State static var progress: Double = 0.75
    static var previews: some View {
        ZStack {
            VStack {
                ZircleProgress(progress: progress,  stroke: .init(lineWidth: 40, lineCap: .round))
                    .glow(vibe: .heavy, soul: .split(left: Asset.Colors.ProgressIndicator.gradientLeft.color, right: Asset.Colors.ProgressIndicator.gradientRight.color))
                    .animation(.easeIn)
                
                Slider(value: $progress)
            }
            .padding(.all, 50)
        }
    }
}
