//
//  CircularFrameBackground.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/29/21.
//

import SwiftUI

struct CircularFrameBackgroundImage: ViewModifier {
    let image: Image
    func body(content: Content) -> some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(1.3, contentMode: .fill)
                .mask(Circle())
            
            content
        }
    }
}

extension CircularFrame {
    func backgroundImage(_ image: Image) -> some View {
        modifier(CircularFrameBackgroundImage(image: image))
    }
}

struct CircularFrameBackground_Previews: PreviewProvider {
    static let size: CGFloat = 300
    static var previews: some View {
        Group {
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout0.image)
                .frame(width: 300, height: 300)
            
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout1.image)
                .frame(width: 300, height: 300)
            
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout2.image)
                .frame(width: 300, height: 300)
            
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout3.image)
                .frame(width: 300, height: 300)
        }
        .preferredColorScheme(.light)
        .previewLayout(.fixed(width: size + 50, height: size + 50))
    }
}
