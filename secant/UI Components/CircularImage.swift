//
//  CircularImageFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 9/29/21.
//

import SwiftUI

struct CircularImage: View {
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    var body: some View {
        image
            .circularBorder
    }
}

struct CircularBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .shadow(radius: 10)
            .overlay(
                GeometryReader { proxy in
                    let lineWidth = proxy.size.width * 0.07
                    
                    Circle()
                        .stroke(
                            lineWidth: lineWidth
                        )
                        .foregroundColor(Asset.Colors.Onboarding.circularFrame.color)
                        // Add two points to the frame to properly mask edges
                        .frame(
                            width: proxy.size.width - lineWidth + 2,
                            height: proxy.size.height - lineWidth + 2,
                            alignment: .center
                        )
                        // Update the offset to account for the 2 extra points
                        .offset(x: lineWidth / 2 - 1, y: lineWidth / 2 - 1)
                }
            )
    }
}

struct BadgeIcon: ViewModifier {
    enum Badge {
        case shield
        case list
        case person

        var image: Image {
            switch self {
            case .shield:   return Asset.Assets.Icons.badge.image
            case .list:     return Asset.Assets.Icons.list.image
            case .person:   return Asset.Assets.Icons.person.image
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

struct CircularImageWithBadge: View {
    enum Version {
        case shielded
        case unified
        case extras
        
        var image: Image {
            switch self {
            case .shielded: return Asset.Assets.Backgrounds.lockImage.image
            case .unified: return Asset.Assets.Backgrounds.lockImage.image
            case .extras: return Asset.Assets.Backgrounds.lockImage.image
            }
        }
        
        var badge: BadgeIcon.Badge {
            switch self {
            case .shielded: return .shield
            case .unified: return .person
            case .extras: return .list
            }
        }
    }
    
    let version: Version
    
    var body: some View {
        CircularImage(image: version.image)
            .badgeIcon(version.badge)
    }
}

extension View {
    var circularBorder: some View {
        modifier(CircularBorder())
    }
    
    func badgeIcon(_ badge: BadgeIcon.Badge) -> some View {
        modifier(BadgeIcon(badge: badge))
    }
}

struct CircularImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Asset.Assets.Backgrounds.lockImage.image
                .frame(width: 300, height: 300)
                .circularBorder
                .badgeIcon(.shield)
                        
            CircularImageWithBadge(version: .shielded)
            
            CircularImage(image: Asset.Assets.Logos.largeYellow.image)
        }
        .preferredColorScheme(.light)
        .previewLayout(.sizeThatFits)
    }
}
