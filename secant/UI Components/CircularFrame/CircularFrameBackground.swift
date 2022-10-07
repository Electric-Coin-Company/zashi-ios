//
//  CircularFrameBackground.swift
//  secant-testnet
//
//  Created by Adam Stener on 10/29/21.
//

import SwiftUI
import ComposableArchitecture

struct CircularFrameBackgroundImages: Animatable, ViewModifier {
    struct ViewState: Equatable {
        let index: Int
        let images: [Image]
    }

    let store: Store<ViewState, Never>
    
    func body(content: Content) -> some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                ForEach(0..<viewStore.images.count - 1, id: \.self) { imageIndex in
                    viewStore.images[imageIndex]
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .opacity(imageIndex == viewStore.index ? 1 : 0)
                        .offset(x: imageIndex <= viewStore.index ? 0 : 25)
                        .mask(Circle())
                        .neumorphic()
                }
                
                content
            }
        }
    }
}

struct CircularFrameBackgroundImage: Animatable, ViewModifier {
    let image: Image
    
    func body(content: Content) -> some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .mask(Circle())
                .neumorphic()
            
            content
        }
    }
}

extension CircularFrame {
    func backgroundImage(_ image: Image) -> some View {
        modifier(CircularFrameBackgroundImage(image: image))
    }
    
    func backgroundImages(_ store: Store<CircularFrameBackgroundImages.ViewState, Never>) -> some View {
        modifier(CircularFrameBackgroundImages(store: store))
    }
}

struct CircularFrameBackground_Previews: PreviewProvider {
    static let size: CGFloat = 300
    static var previews: some View {
        Group {
            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout0.image)
                .frame(width: 300, height: 300)
                .applyScreenBackground()
                .neumorphic()

            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout1.image)
                .frame(width: 300, height: 300)
                .applyScreenBackground()
                .neumorphic()

            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout2.image)
                .frame(width: 300, height: 300)
                .applyScreenBackground()
                .neumorphic()

            CircularFrame()
                .backgroundImage(Asset.Assets.Backgrounds.callout3.image)
                .frame(width: 300, height: 300)
                .applyScreenBackground()
                .neumorphic()
                .preferredColorScheme(.dark)
        }
        .preferredColorScheme(.light)
        .previewLayout(.fixed(width: size + 50, height: size + 50))
    }
}
