//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 1/6/22.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct WelcomeView: View {
    var store: WelcomeStore
    
    @State var animate: Bool = false
    
    public init(store: WelcomeStore) {
        self.store = store
    }

    public var body: some View {
            VStack {
                ZStack {
                    ZStack {
                            VStack(spacing: 27) {
                                Image(Asset.Assets.welcomeScreenLogo.name)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                Text(L10n.WelcomeScreen.description)
                                    .font(
                                        .custom(FontFamily.Inter.regular.name, size: 22)
                                        .weight(.regular)
                                    )
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                                    .frame(width: 277, height: 147, alignment: .top)
                                Spacer()
                            }
                            .padding(.top, 75.0)
                            .accessDebugMenuWithHiddenGesture {
                                ViewStore(store).send(.debugMenuStartup)
                            }
                    }
                    ZStack {
                        LinearGradient(colors: [Asset.Colors.BackgroundColors.splashBGColor.color, Asset.Colors.BackgroundColors.splashBGColor.color, .clear], startPoint: .top, endPoint: .bottom)
                        
                        VStack() {
                            Spacer()
                            Asset.Assets.splashBG.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                
                                .frame(height: UIScreen.main.bounds.height)
                        }
                        VStack(spacing: 44) {
                            Asset.Assets.isolationModeLogo.image
                                .resizable()
                                .frame(width: 83, height: 107)
                            Asset.Assets.isolationModeLogoText.image
                                .frame(width: 82, height: 71)
                        }
                        .padding(.top, 75)
                    }
                    .offset(y: animate ? -(UIScreen.main.bounds.height) : 0)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .padding(.top, 50)
            .applyScreenBackground()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation(.interpolatingSpring(stiffness: 20, damping: 8)
                        .speed(0.5)
                    ) {
                        animate.toggle()
                    }
                }
            }
        }
}

// MARK: - Previews

struct WelcomeView_Previews: PreviewProvider {
    static let squarePreviewSize: CGFloat = 360

    static var previews: some View {
        ZcashBadge()
            .applyScreenBackground()
            .previewLayout(
                .fixed(
                    width: squarePreviewSize,
                    height: squarePreviewSize
                )
            )
            .preferredColorScheme(.light)

        ZStack {
            ZcashBadge()
        }
        .padding()
        .applyScreenBackground()
        .previewLayout(
            .fixed(
                width: squarePreviewSize,
                height: squarePreviewSize
            )
        )
        .preferredColorScheme(.light)

        Group {
            WelcomeView(store: .demo)
                .preferredColorScheme(.light)

            WelcomeView(store: .demo)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
