//
//  CircularImageFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 9/29/21.
//

import SwiftUI

struct BadgeIcon: ViewModifier {
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

    let badge: Badge

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
                                    width: proxy.size.width * 0.5,
                                    height: proxy.size.height * 0.5,
                                    alignment: .center
                                )
                                .offset(
                                    x: 0.0,
                                    y: proxy.size.height * 0.21
                                )
                            Spacer()
                        }
                    }
                }
            )
    }
}

extension View {
    func badgeIcon(_ badge: BadgeIcon.Badge) -> some View {
        modifier(BadgeIcon(badge: badge))
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
