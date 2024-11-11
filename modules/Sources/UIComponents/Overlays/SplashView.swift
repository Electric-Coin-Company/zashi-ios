//
//  SplashView.swift
//
//
//  Created by Lukáš Korba on 27.09.2023.
//

import SwiftUI
import Generated
import LocalAuthenticationHandler
import ComposableArchitecture
import Models

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
    @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial

    let isHidden: Bool
    let screenSize: CGSize
    var task: Task<(), Never>?
    var currentMaxHeight: CGFloat = 0.0
    var step: CGFloat = 0.0
    @Published var authenticationDidntSucceed = false
    @Published var isOn = true
    let completion: () -> Void
    var timer: Timer?

    init(_ isHidden: Bool, completion: @escaping () -> Void) {
        self.isHidden = isHidden
        self.screenSize = UIScreen.main.bounds.size
        self.completion = completion
        
        if !isHidden {
            preparePoints()
            if featureFlags.appLaunchBiometric {
                authenticate()
            } else {
                Task {
                    await self.spinTheWheel()
                }
            }
        }
    }

    func authenticate() {
        @Dependency(\.localAuthentication) var localAuthentication

        authenticationDidntSucceed = false
        
        Task {
            if await !localAuthentication.authenticate() {
                await self.authenticationFailed()
            } else {
                await self.spinTheWheel()
            }
        }
    }
    
    @MainActor func authenticationFailed() {
        authenticationDidntSucceed = true
    }
    
    @MainActor func spinTheWheel() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
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
    var authenticationIcon: Image {
        @Dependency(\.localAuthentication) var localAuthentication

        switch localAuthentication.method() {
        case .faceID: return Image(systemName: "faceid")
        case .touchID: return Image(systemName: "touchid")
        case .passcode: return Asset.Assets.Icons.authKey.image
        default: return Asset.Assets.Icons.coinsHand.image
        }
    }

    var authenticationDesc: String {
        @Dependency(\.localAuthentication) var localAuthentication

        switch localAuthentication.method() {
        case .faceID: return L10n.Splash.authFaceID
        case .touchID: return L10n.Splash.authTouchID
        case .passcode: return L10n.Splash.authPasscode
        default: return ""
        }
    }

    var body: some View {
        if splashManager.isOn && !isHidden {
            ZStack {
                GeometryReader { proxy in
                    Asset.Assets.zashiLogo.image
                        .zImage(width: 249, height: 321, color: .white)
                        .scaleEffect(0.35)
                        .position(
                            x: proxy.frame(in: .local).midX,
                            y: proxy.frame(in: .local).midY * 0.5
                        )
                    
                    Asset.Assets.splashHi.image
                        .zImage(width: 246, height: 213, color: .white)
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
                .onChange(of: isHidden) { value in
                    if value {
                        splashManager.preparePoints()
                    }
                }
                if splashManager.authenticationDidntSucceed {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Button {
                            splashManager.authenticate()
                        } label: {
                            authenticationIcon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                        }

                        Text(L10n.Splash.authTitle)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 24)

                        Text(authenticationDesc)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 120)
                    .screenHorizontalPadding()
                }
            }
        }
    }
}

struct SplashModifier: ViewModifier {
    let isHidden: Bool
    let completion: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isHidden {
                    SplashView(
                        splashManager: SplashManager(isHidden) {
                            completion()
                        },
                        isHidden: isHidden
                    )
                    .hidden()
                } else {
                    SplashView(
                        splashManager: SplashManager(isHidden) {
                            completion()
                        },
                        isHidden: isHidden
                    )
                }
            }
    }
}

extension View {
    public func overlayedWithSplash(_ isHidden: Bool = false, completion: @escaping () -> Void) -> some View {
        modifier(SplashModifier(isHidden: isHidden, completion: completion))
    }
}
