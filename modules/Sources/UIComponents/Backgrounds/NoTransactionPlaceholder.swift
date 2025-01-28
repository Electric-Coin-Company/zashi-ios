//
//  NoTransactionPlaceholder.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-22-2025.
//

import SwiftUI
import Generated

public struct ShimmerConfiguration {
    public let gradient: Gradient
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    public let duration: TimeInterval
    public let opacity: Double
    public static let `default` = ShimmerConfiguration(
        gradient: Gradient(stops: [
            .init(color: .black, location: 0),
            .init(color: .white, location: 0.3),
            .init(color: .white, location: 0.7),
            .init(color: .black, location: 1),
        ]),
        initialLocation: (start: UnitPoint(x: -1, y: 0.5), end: .leading),
        finalLocation: (start: .trailing, end: UnitPoint(x: 2, y: 0.5)),
        duration: 1.5,
        opacity: 0.15
    )
}

public struct ShimmeringView<Content: View>: View {
    let on: Bool
    private let content: () -> Content
    private let configuration: ShimmerConfiguration
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    
    public init(on: Bool, configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
        self.on = on
        self.configuration = configuration
        self.content = content
        _startPoint = .init(wrappedValue: configuration.initialLocation.start)
        _endPoint = .init(wrappedValue: configuration.initialLocation.end)
    }
    
    public var body: some View {
        ZStack {
            content()
            LinearGradient(
                gradient: configuration.gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .opacity(configuration.opacity)
            .blendMode(.screen)
            .onAppear {
                if on {
                    withAnimation(Animation.linear(duration: configuration.duration).repeatForever(autoreverses: false)) {
                        startPoint = configuration.finalLocation.start
                        endPoint = configuration.finalLocation.end
                    }
                }
            }
        }
    }
}

public struct ShimmerModifier: ViewModifier {
    let on: Bool
    let configuration: ShimmerConfiguration

    public func body(content: Content) -> some View {
        ShimmeringView(on: on, configuration: configuration) { content }
    }
}


public extension View {
    func shimmer(_ on: Bool = false, configuration: ShimmerConfiguration = .default) -> some View {
        modifier(ShimmerModifier(on: on, configuration: configuration))
    }
}

public struct NoTransactionPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme
    let isShimmerOn: Bool
    
    public init(_ isShimmerOn: Bool = false) {
        self.isShimmerOn = isShimmerOn
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Circle()
                .shimmer(isShimmerOn).clipShape(Circle())
                .frame(width: 40, height: 40)
                .zForegroundColor(Design.Surfaces.bgSecondary)
                .padding(.trailing, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .shimmer(isShimmerOn).clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(width: 86, height: 14)
                
                RoundedRectangle(cornerRadius: 7)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .shimmer(isShimmerOn).clipShape(RoundedRectangle(cornerRadius: 7))
                    .frame(width: 64, height: 14)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 7)
                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                .shimmer(isShimmerOn).clipShape(RoundedRectangle(cornerRadius: 7))
                .frame(width: 32, height: 14)
        }
        .screenHorizontalPadding()
        .padding(.vertical, 12)
    }
}
