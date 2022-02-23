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

    @ViewBuilder var image: some View {
        switch self {
        case .shield:
            Asset.Assets.Icons.shield.image
                .resizable()
                .renderingMode(.none)
        case .list:
            Asset.Assets.Icons.list.image
                .resizable()
                .renderingMode(.none)
        case .person:
            Asset.Assets.Icons.profile.image
                .resizable()
                .renderingMode(.none)
        case .error:
            ErrorBadge()
        }
    }
}

struct ErrorBadge: View {
    var body: some View {
        Text("X")
            .font(.custom(FontFamily.Rubik.bold.name, size: 36))
            .foregroundColor(Asset.Colors.BackgroundColors.red.color)
            .frame(width: 60, height: 55, alignment: .center)
            .background(Asset.Colors.BackgroundColors.numberedChip.color)
            .cornerRadius(10)
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
                                    ForEach(0..<viewStore.badges.count) { badgeIndex in
                                        viewStore.badges[viewStore.index].image
                                            .frame(
                                                width: proxy.size.width * 0.35,
                                                height: proxy.size.height * 0.35,
                                                alignment: .center
                                            )
                                            .offset(
                                                x: 4.0,
                                                y: proxy.size.height * 0.15
                                            )
                                            .opacity(badgeIndex == viewStore.index ? 1 : 0)
                                            .shadow(
                                                color: Asset.Colors.Onboarding.badgeShadow.color,
                                                radius: 10,
                                                x: 0,
                                                y: 0
                                            )
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
                                .offset(
                                    x: 4.0,
                                    y: proxy.size.height * 0.15
                                )
                                .transition(.scale(scale: 2))
                                .transition(.opacity)
                                .shadow(
                                    color: Asset.Colors.Onboarding.badgeShadow.color,
                                    radius: 10,
                                    x: 0,
                                    y: 0
                                )
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
    }
}
