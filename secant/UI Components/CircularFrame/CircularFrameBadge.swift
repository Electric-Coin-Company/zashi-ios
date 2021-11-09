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

    var image: Image {
        switch self {
        case .shield: return Asset.Assets.Icons.shield.image
        case .list: return Asset.Assets.Icons.list.image
        case .person: return Asset.Assets.Icons.profile.image
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
                                    ForEach(0..<viewStore.badges.count) { badgeIndex in
                                        viewStore.badges[viewStore.index].image
                                            .resizable()
                                            .renderingMode(.none)
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
                                .resizable()
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
        }
        .preferredColorScheme(.light)
        .previewLayout(.fixed(width: size + 50, height: size + 50))
    }
}
