//
//  CircularImageFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 9/29/21.
//

import SwiftUI

struct CircularImage: View {
    var imageName: String
    var color: Color
    var size: CGFloat
    
    init(
        named: String,
        withColor color: Color = .circularFrame,
        size: CGFloat = 300
    ) {
        imageName = named
        self.color = color
        self.size = size
    }
    
    var body: some View {
        Image(imageName)
            .frame(
                width: size,
                height: size,
                alignment: .center
            )
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
                        let lineWidth = proxy.size.width * 0.06
                        
                        Circle()
                            .stroke(
                                lineWidth: lineWidth
                            )
                            //Add two points to the frame to properly mask edges
                            .frame(
                                width: proxy.size.width - lineWidth + 2,
                                height: proxy.size.height - lineWidth + 2,
                                alignment: .center
                            )
                            //Update the offset to account for the 2 extra points
                            .offset(x: lineWidth / 2 - 1, y: lineWidth / 2 - 1)
                    }
                )
    }
}

struct BadgeIcon: ViewModifier {
    enum Badge {
        case badge
        case list
        case person

        var assetName: String {
            switch self {
            case .badge:    return "icon_badge"
            case .list:     return "icon_list"
            case .person:   return "icon_person"
            }
        }
        
        var image: Image {
            return Image(assetName, bundle: .main)
        }
    }
    
    let badge: Badge

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    badge.image
                        .offset(x: 5, y: 60)
                }
            )
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

extension Color {
    static var circularFrame: Self {
        return Color.init("OnboardingCircularFrame", bundle: .main)
    }
}

struct CircularImageBorder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Applied to an Image directly
            Image("LockImage")
                .frame(width: 300, height: 300)
                .circularBorder
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            Image("LockImage")
                .frame(width: 300, height: 300)
                .circularBorder
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            // Helper View with modifier pre-applied
            CircularImage(named: "LockImage")
                .badgeIcon(.person)
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
