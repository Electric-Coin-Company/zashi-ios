//
//  SmartBanner.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-14.
//

import SwiftUI
import Generated

struct BottomRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height - radius))

            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: height),
                control: CGPoint(x: width, y: height)
            )
            
            path.addLine(to: CGPoint(x: radius, y: height))

            path.addQuadCurve(
                to: CGPoint(x: 0, y: height - radius),
                control: CGPoint(x: 0, y: height)
            )
            
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: radius))

            path.addQuadCurve(
                to: CGPoint(x: width - radius, y: 0),
                control: CGPoint(x: width, y: 0)
            )
            
            path.addLine(to: CGPoint(x: radius, y: 0))

            path.addQuadCurve(
                to: CGPoint(x: 0, y: radius),
                control: CGPoint(x: 0, y: 0)
            )
            
            path.addLine(to: CGPoint(x: 0, y: 0))
        }
    }
}

enum Constants {
    static let fixedHeight: CGFloat = 32
    static let fixedHeightWithShadow: CGFloat = 36
    static let shadowHeight: CGFloat = 4
}

public struct SmartBanner<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var realHeight: CGFloat = 100
    @State private var isOpen = false
    @State private var isUnhidden = false
    @State private var height: CGFloat = 0
    let content: () -> Content?

    var test = false
    
    public init(isOpen: Bool = false, content: @escaping () -> Content?) {
        self.content = content
//        if isOpen {
//            withAnimation {
        test = isOpen
//            }
//        }
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            BottomRoundedRectangle(radius: Constants.fixedHeight)
                .frame(height: Constants.fixedHeight)
                .foregroundColor(Design.screenBackground.color(colorScheme))
                .shadow(color: Design.Text.primary.color(colorScheme).opacity(0.25), radius: 1)
                .zIndex(1)

            VStack(spacing: 0) {
                if isOpen {
                    content()
                        .padding(.vertical, 24)
                        .padding(.top, Constants.fixedHeight)
                        .screenHorizontalPadding()
                }
                
                TopRoundedRectangle(radius: isOpen ? Constants.fixedHeight : 0)
                    .frame(height: Constants.fixedHeightWithShadow)
                    .foregroundColor(Design.screenBackground.color(colorScheme))
                    .shadow(color: Design.Text.primary.color(colorScheme).opacity(0.1), radius: isOpen ? 1 : 0, y: -1)
            }
            .frame(minHeight: Constants.fixedHeight + Constants.shadowHeight)
        }
        .background {
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: colorScheme == .dark
                        ? Color(UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1))
                        : Design.Utility.Gray._300.color(colorScheme),
                        location: 0.00
                    ),
                    Gradient.Stop(color: Design.screenBackground.color(colorScheme), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.0),
                endPoint: UnitPoint(x: 0.5, y: 0.8)
            )
        }
        .clipShape( Rectangle() )
        .onTapGesture {
            withAnimation {
                isOpen.toggle()
            }
        }
//        .task { @MainActor in
//            try? await Task.sleep(for: .seconds(2))
//            if test {
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    isOpen.toggle()
//                }
//            }
//        }
    }
}
