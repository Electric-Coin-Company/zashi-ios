//
//  SplashView.swift
//
//
//  Created by Lukáš Korba on 27.09.2023.
//

import SwiftUI
import Generated

private final class SplashManager: ObservableObject {
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

    let screenSize: CGSize
    var task: Task<(), Never>?
    var currentMaxHeight: CGFloat = 0.0
    var step: CGFloat = 0.0
    var isOn = true
    
    init() {
        self.screenSize = UIScreen.main.bounds.size
        preparePoints()
        self.spinTheWheel()
    }
    
    func spinTheWheel() {
        let start = Date.now.timeIntervalSince1970
        
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            if self.isOn {
                Task {
                    await self.tick()
                    
                    if self.currentMaxHeight <= 0.0 {
                        let end = Date.now.timeIntervalSince1970
                        print("end of animation \(end - start)")
                        self.isOn.toggle()
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
                prevHeight += CGFloat.random(in: 10...40)
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
}

struct SplashView: View {
    @StateObject private var splashManager = SplashManager()
    
    var body: some View {
        if splashManager.isOn {
            GeometryReader { proxy in
                Asset.Assets.zashiLogo.image
                    .resizable()
                    .frame(width: 249, height: 321)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.5
                    )
                
                Asset.Assets.splashHi.image
                    .resizable()
                    .frame(width: 246, height: 213)
                    .scaleEffect(0.35)
                    .position(
                        x: proxy.frame(in: .local).midX,
                        y: proxy.frame(in: .local).midY * 0.8
                    )
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
    func body(content: Content) -> some View {
        content
            .overlay {
                SplashView()
            }
    }
}

extension View {
    public func overlayedWithSplash() -> some View {
        modifier(SplashModifier())
    }
}
