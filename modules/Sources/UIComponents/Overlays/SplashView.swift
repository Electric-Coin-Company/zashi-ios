//
//  SplashView.swift
//
//
//  Created by Lukáš Korba on 27.09.2023.
//

import SwiftUI
import Generated

final class SplashManager: ObservableObject {
    struct SplashShape: Shape {
        var points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                points.forEach { path.addLine(to: $0) }
                path.closeSubpath()
            }
        }
    }

    @Published var points: [CGPoint] = []

    let isHidden: Bool
    let screenSize: CGSize
    var task: Task<(), Never>?
    var currentMaxHeight: CGFloat = 0.0
    var step: CGFloat = 0.0
    @Published var isOn = true
    let completion: () -> Void

    init(_ isHidden: Bool, completion: @escaping () -> Void) {
        self.isHidden = isHidden
        self.screenSize = UIScreen.main.bounds.size
        self.completion = completion
        
        if !isHidden {
            preparePoints()
            self.spinTheWheel()
        }
    }
    
    func spinTheWheel() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            if self.isOn {
                Task {
                    await self.tick()
                    
                    if self.currentMaxHeight <= 0.0 {
                        await self.finished()
                    }
                }
            }
        }
    }
    
    func preparePoints() {
        let pointsInControl = Int.random(in: 4...7)
        let allPoints = pointsInControl + 1
        let rangeSize = screenSize.width / CGFloat(allPoints)
        let xOffsetHelper = screenSize.width * 0.05
        
        var prevHeight = 0.0
        
        for i in stride(from: allPoints, through: 0, by: -1) {
            // x
            var randomXOffset: CGFloat = 0.0
            
            if i > 0 && i < allPoints {
                randomXOffset = CGFloat.random(in: -xOffsetHelper...xOffsetHelper)
            }
            
            let x = rangeSize * CGFloat(i) + randomXOffset
            
            // y
            let y = screenSize.height + prevHeight
            
            if (allPoints - i) % 2 == 0 {
                prevHeight += CGFloat.random(in: 30...70)
            }

            points.append(CGPoint(x: x, y: y))
        }
        
        points.reverse()
        
        var maxHeight: CGFloat = 0.0
        
        points.forEach {
            if $0.y > maxHeight {
                maxHeight = $0.y
            }
        }
        
        currentMaxHeight = maxHeight
        step = currentMaxHeight / 100.0
    }
    
    @MainActor func tick() {
        step *= 1.04
        
        var newMaxHeight: CGFloat = 0.0
        
        points = points.enumerated().map {
            let y = $0.element.y - step
            
            if y > newMaxHeight {
                newMaxHeight = y
            }
            return CGPoint(x: $0.element.x, y: y)
        }
        
        currentMaxHeight = newMaxHeight
    }
    
    @MainActor func finished() {
        self.isOn.toggle()
        completion()
    }
}

struct SplashView: View {
    @StateObject var splashManager: SplashManager
    let isHidden: Bool
    
    var body: some View {
        if splashManager.isOn && !isHidden {
            GeometryReader { proxy in
                Asset.Assets.zashiLogo.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 249, height: 321)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.5
                    )
                    .foregroundColor(.white)

                Asset.Assets.splashHi.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 246, height: 213)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.8
                    )
                    .foregroundColor(.white)
            }
            .background(Asset.Colors.splash.color)
            .mask {
                SplashManager.SplashShape(points: splashManager.points)
            }
            .ignoresSafeArea()
        }
    }
}

struct SplashModifier: ViewModifier {
    let isHidden: Bool
    let completion: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                SplashView(
                    splashManager: SplashManager(isHidden) {
                        completion()
                    },
                    isHidden: isHidden
                )
            }
    }
}

extension View {
    public func overlayedWithSplash(_ isHidden: Bool = false, completion: @escaping () -> Void) -> some View {
        modifier(SplashModifier(isHidden: isHidden, completion: completion))
    }
}
