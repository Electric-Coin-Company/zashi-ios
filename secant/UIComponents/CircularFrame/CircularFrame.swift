//
//  CircularImageFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 9/29/21.
//

import SwiftUI

struct CircularFrame: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { proxy in
            let lineWidth = proxy.size.width * 0.06
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Asset.Colors.Onboarding.circularFrameGradientStart.color,
                            Asset.Colors.Onboarding.circularFrameGradientEnd.color
                        ],
                        startPoint: colorScheme == .light ? .topLeading : .top,
                        endPoint: colorScheme == .light ? .bottomTrailing : .bottom
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth
                    )
                )
                .padding(colorScheme == .light ? 0 : 10)

            if colorScheme == .dark {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Asset.Colors.Onboarding.circularFrameDarkOutlineGradientStart.color,
                                Asset.Colors.Onboarding.circularFrameDarkOutlineGradientEnd.color
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(
                            lineWidth: lineWidth * 0.15
                        )
                    )
            }
        }
    }
}

struct OnboardingCircularFrame: View {
    @Binding var index: Int
    let size: CGFloat

    var body: some View {
        ZStack {
            CircularFrame()
                .frame(width: size, height: size)
            
            switch index {
            case 0:
                Asset.Assets.Icons.shield.image
                    .onboardingBadge(parentSize: size)
            case 1:
                Asset.Assets.Icons.profile.image
                    .onboardingBadge(parentSize: size)
            case 2:
                Asset.Assets.Icons.list.image
                    .onboardingBadge(parentSize: size)
            default:
                EmptyView()
            }
        }
    }
}

extension Image {
    func onboardingBadge(parentSize: CGFloat) -> some View {
        self
            .resizable()
            .frame(width: parentSize / 2, height: parentSize / 2)
            .offset(y: parentSize * 0.47)
            .zIndex(100)
    }
}

struct CircularFramePreviewHelper: View {
    @State var index = 0
    private let size: CGFloat = 300
    
    var body: some View {
        VStack {
            HStack(spacing: 25) {
                Button("+") {
                    guard index < 2 else { return }
                    index += 1
                }
                
                Button("-") {
                    guard index != 0 else { return }
                    index -= 1
                }
                
                Text("\(index)")
            }
            
            GeometryReader { proxy in
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        OnboardingCircularFrame(index: $index, size: proxy.size.width / 2)
                            .animation(.easeInOut(duration: 2), value: index)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout1.image)
                .frame(width: size, height: size)
                .badgeIcon(.shield)
            
            Spacer()
        }
    }
}

struct CircularFrame_Previews: PreviewProvider {
    static var previews: some View {
        CircularFramePreviewHelper()
            .preferredColorScheme(.dark)
            .previewLayout(.device)
            .applyScreenBackground()
    }
}
