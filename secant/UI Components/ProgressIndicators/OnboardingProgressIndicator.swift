//
//  OnboardingProgressIndicator.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/15/21.
//

import SwiftUI

struct OnboardingProgressStyle: ProgressViewStyle {
    let height: CGFloat = 3
    let gradient = LinearGradient(
        colors: [
            Asset.Colors.ProgressIndicator.gradientLeft.color,
            Asset.Colors.ProgressIndicator.gradientRight.color
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return VStack {
            HStack {
                configuration.label
                    .foregroundColor(Asset.Colors.Text.heading.color)
                    .font(.custom(FontFamily.Rubik.regular.name, size: 16))
                    .opacity(0.3)
                
                Spacer()
            }
            
            ZStack {
                GeometryReader { proxy in
                    let currentWidth = proxy.size.width
                    let progressMaxWidth = currentWidth * CGFloat(fractionCompleted)
                    let trailingMaxWidth = currentWidth - (currentWidth * CGFloat(fractionCompleted))
                    
                    HStack(spacing: 15) {
                        if fractionCompleted > 0 {
                            Capsule()
                                .fill(gradient)
                                .frame(maxWidth: progressMaxWidth)
                        }
                       
                        if fractionCompleted < 1 {
                            Capsule()
                                .fill(Asset.Colors.ProgressIndicator.negativeSpace.color)
                                .frame(maxWidth: trailingMaxWidth)
                        }
                    }
                }
                .frame(height: height)
                .animation(.easeInOut, value: fractionCompleted)
            }
        }
    }
}

// MARK: - ProgressView : onboardingProgressStyle

extension ProgressView {
    var onboardingProgressStyle: some View {
        progressViewStyle(OnboardingProgressStyle())
    }
}

// MARK: - Interactive ProgressStyle View

struct OnboardingProgressViewPreviewHelper: View {
    @State private var value: CGFloat = 35.0
    
    var progressString: String {
        String(format: "%02d", value)
    }
    
    var body: some View {
        VStack(spacing: 50) {
            ProgressView(
                "\(Int(value))",
                value: value,
                total: 100
            )
            .onboardingProgressStyle
            
            Slider(value: $value, in: 0...100, step: 1)
        }
        .padding(.horizontal)
    }
}

// MARK: - Previews

struct OnboardingProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingProgressViewPreviewHelper()
    }
}
