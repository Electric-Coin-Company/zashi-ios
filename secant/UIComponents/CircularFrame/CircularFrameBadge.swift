//
//  CircularImageFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 9/29/21.
//

import SwiftUI
import ComposableArchitecture

enum Badge: Equatable {
    case shield
    case list
    case person
    case error

    private func badgeSymbol() -> Image? {
        switch self {
        case .shield:
            return Asset.Assets.Icons.shield.image
        case .list:
            return Asset.Assets.Icons.list.image
        case .person:
            return Asset.Assets.Icons.profile.image
        default:
            return nil
        }
    }
    
    @ViewBuilder var image: some View {
        if self == .error {
            ErrorBadge()
        } else {
            if let symbol = badgeSymbol() {
                IconBadge(image: symbol)
            }
        }
    }
}

struct ErrorBadge: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Asset.Colors.Onboarding.circularFrameGradientStart.color,
                            Asset.Colors.Onboarding.circularFrameGradientEnd.color
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 60, height: 60, alignment: .center)
                .cornerRadius(10)
            
            Rectangle()
                .fill(Asset.Colors.Onboarding.badgeBackground.color)
                .frame(width: 55, height: 55, alignment: .center)
                .cornerRadius(10)
                .shadow(
                    color: Asset.Colors.Onboarding.badgeShadow.color,
                    radius: 10,
                    x: 0,
                    y: 0
                )
            
            Text("X")
                .font(.custom(FontFamily.Rubik.bold.name, size: 36))
                .foregroundColor(Asset.Colors.BackgroundColors.red.color)
        }
    }
}

struct IconBadge: View {
    let image: Image
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Asset.Colors.Onboarding.circularFrameGradientStart.color,
                            Asset.Colors.Onboarding.circularFrameGradientEnd.color
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 60, height: 60, alignment: .center)
                .cornerRadius(10)

            Rectangle()
                .fill(Asset.Colors.Onboarding.badgeBackground.color)
                .frame(width: 55, height: 55, alignment: .center)
                .cornerRadius(10)
                .shadow(
                    color: Asset.Colors.Onboarding.badgeShadow.color,
                    radius: 10,
                    x: 0,
                    y: 0
                )

            image
                .resizable()
                .renderingMode(.none)
                .scaledToFill()
                .frame(width: 60, height: 60)
        }
    }
}

struct BadgesOverlay: Animatable, ViewModifier {
    struct ViewState: Equatable {
        let index: Int
        let badges: [Badge]
    }
    
    let store: Store<ViewState, Never>
    
    func body(content: Content) -> some View {
        WithViewStore(self.store) { viewStore in
            content
                .overlay(
                    GeometryReader { proxy in
                        VStack {
                            Spacer()

                            HStack {
                                Spacer()

                                ZStack {
                                    ForEach(0..<viewStore.badges.count, id: \.self) { badgeIndex in
                                        viewStore.badges[viewStore.index].image
                                            .frame(
                                                width: proxy.size.width * 0.35,
                                                height: proxy.size.height * 0.35,
                                                alignment: .center
                                            )
                                            .offset(y: proxy.size.height * 0.16)
                                            .opacity(badgeIndex == viewStore.index ? 1 : 0)
                                    }
                                }
                               
                                Spacer()
                            }
                        }
                    }
                )
        }
    }
}

struct BadgeOverlay: Animatable, ViewModifier {
    var badge: Badge

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    VStack {
                        Spacer()

                        HStack {
                            Spacer()

                            badge.image
                                .frame(
                                    width: proxy.size.width * 0.35,
                                    height: proxy.size.height * 0.35,
                                    alignment: .center
                                )
                                .offset(y: proxy.size.height * 0.16)
                                .transition(.scale(scale: 2))
                                .transition(.opacity)
                            Spacer()
                        }
                    }
                }
            )
    }
}

extension View {
    func badgeIcon(_ badge: Badge) -> some View {
        modifier(BadgeOverlay(badge: badge))
    }
    
    func badgeIcons(_ store: Store<BadgesOverlay.ViewState, Never>) -> some View {
        modifier(BadgesOverlay(store: store))
    }
}

struct Badge_Previews: PreviewProvider {
    static let size: CGFloat = 300
    
    static var previews: some View {
        Group {
            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.shield)
            
            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.list)

            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.person)

            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.error)
        }
        .preferredColorScheme(.light)
        .previewLayout(.fixed(width: size + 50, height: size + 50))

        Group {
            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.shield)
            
            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.list)

            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.person)

            CircularFrame()
                .frame(width: size, height: size)
                .badgeIcon(.error)
        }
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: size + 50, height: size + 50))
    }
}
