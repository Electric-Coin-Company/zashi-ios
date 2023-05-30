//
//  CircularProgress.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 27.06.2022.
//

import SwiftUI
import Generated

struct CircularProgress: View {
    let outerCircleProgress: Float
    let innerCircleProgress: Float
    let maxSegments: Int
    let innerCircleHidden: Bool

    var outerCircleProgressCG: CGFloat {
        CGFloat(outerCircleProgress)
    }

    var innerCircleProgressCG: CGFloat {
        CGFloat(innerCircleProgress)
    }

    var body: some View {
        let segmentTrimComputed = segmentTrim
        let gap = (2.0 / 360.0) // 2 degrees
        
        return ZStack {
            if !innerCircleHidden {
                Circle()
                    .trim(
                        from: 0.0,
                        to: innerCircleProgressCG
                    )
                    .stroke(
                        Asset.Colors.ProgressIndicator.negativeSpace.color,
                        style: StrokeStyle(lineWidth: 17.0, dash: [2])
                    )
                    .rotationEffect(Angle(degrees: -90))
            }

            ForEach((0..<maxSegments), id: \.self) {
                Circle()
                    .trim(
                        from: fromValue($0, segmentTrimComputed, 1.0),
                        to: toValue($0, segmentTrimComputed, 1.0, gap)
                    )
                    .stroke(
                        Asset.Colors.ProgressIndicator.negativeSpace.color,
                        lineWidth: 5.0
                    )
                    .scaleEffect(1.15)
                    .opacity(0.2)
                    .rotationEffect(Angle(degrees: -90))
                
                Circle()
                    .trim(
                        from: fromValue($0, segmentTrimComputed, outerCircleProgressCG),
                        to: toValue($0, segmentTrimComputed, outerCircleProgressCG, gap)
                    )
                    .stroke(
                        Asset.Colors.ProgressIndicator.negativeSpace.color,
                        lineWidth: 5.0
                    )
                    .scaleEffect(1.15)
                    .rotationEffect(Angle(degrees: -90))
            }
        }
    }
}
                    
extension CircularProgress {
    var segmentTrim: CGFloat {
        guard maxSegments != 0 else { return 1.0 }
        return CGFloat(1.0 / Double(maxSegments))
    }
    
    func fromValue(_ segmentIndex: Int, _ segmentTrim: CGFloat, _ progress: CGFloat) -> CGFloat {
        var result = segmentTrim * CGFloat(segmentIndex)
        
        if result > progress {
            result = 0
        }
        
        return result
    }

    func toValue(_ segmentIndex: Int, _ segmentTrim: CGFloat, _ progress: CGFloat, _ gap: CGFloat) -> CGFloat {
        var result = fromValue(segmentIndex, segmentTrim, progress)
        
        if result > progress {
            result = 0
        } else if result + segmentTrim - gap < progress {
            result += segmentTrim - gap
        } else {
            result += progress - (segmentTrim * CGFloat(segmentIndex)) - gap
        }
        
        return result
    }
}

struct CircularProgress_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            CircularProgress(
                outerCircleProgress: 0.33,
                innerCircleProgress: 0.8,
                maxSegments: 10,
                innerCircleHidden: true
            )
            .frame(width: proxy.size.width * 0.8, height: proxy.size.width * 0.8)
            .offset(x: 40, y: 200)
        }
        .applyScreenBackground()
        .preferredColorScheme(.light)
    }
}
