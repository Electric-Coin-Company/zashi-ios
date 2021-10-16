//
//  ZcashButtonBackground.swift
//  wallet
//
//  Created by Francisco Gindre on 3/3/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import SwiftUI

enum ZcashFillStyle {
    case gradient(gradient: LinearGradient)
    case solid(color: Color)
    case outline(color: Color, lineWidth: CGFloat)
    
    func fill<S: Shape>(_ shape: S) -> AnyView {
        switch self {
        case .gradient(let grad):
            return AnyView(shape.fill(grad))
        case .solid(let color):
            return AnyView(shape.fill(color))
        case .outline(color: let color, lineWidth: let lineWidth):
            return AnyView(
                shape.stroke(color, lineWidth: lineWidth)
            )
        }
    }
}

struct ZcashButtonBackground: ViewModifier {
    enum BackgroundShape {
        case chamfered(fillStyle: ZcashFillStyle)
        case rounded(fillStyle: ZcashFillStyle)
        case roundedCorners(fillStyle: ZcashFillStyle)
    }
    
    var buttonShape: BackgroundShape
    init(buttonShape: BackgroundShape) {
        self.buttonShape = buttonShape
    }
    
    func backgroundWith(geometry: GeometryProxy, backgroundShape: BackgroundShape) -> AnyView {
        
        switch backgroundShape {
        case .chamfered(let fillStyle):
            
            return AnyView (
                fillStyle.fill( ZcashChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0))
            )
        case .rounded(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ZcashRoundedButtonBackground()
                )
            )
        case .roundedCorners(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ZcashRoundCorneredButtonBackground()
                )
            )
        
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { geometry in
                self.backgroundWith(geometry: geometry, backgroundShape: self.buttonShape)
            }
            content
            
        }
    }
}

extension Text  {
    func zcashButtonBackground(shape: ZcashButtonBackground.BackgroundShape) -> some View {
        self.modifier(ZcashButtonBackground(buttonShape: shape))
    }
}


struct ZcashButtonBackground_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
//            ZcashBackground()
//            Color.background
            VStack(spacing: 40) {
                
                Text("Savings Circle")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .shadow(color:Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.2), radius: 1, x: 0, y: 2)
                    .foregroundColor(Asset.Colors.Text.button.color)
                    .modifier(ZcashButtonBackground(buttonShape: .roundedCorners(fillStyle: .solid(color: Asset.Colors.Buttons.primaryButton.color))))
                   
                    .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.3), radius: 15, x: 10, y: 15)
                     .shadow(color: Color.white.opacity(0.5), radius: 25, x:-10, y: -10)
                    .frame(height: 50)
                   
                Text("Savings Goal")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .shadow(color:Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.2), radius: 1, x: 0, y: 2)
                .foregroundColor(Asset.Colors.Buttons.primaryButton.color)
                    .modifier(ZcashButtonBackground(buttonShape: .roundedCorners(fillStyle: .solid(color: Asset.Colors.Text.button.color))))
                
                    .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.5), radius: 25, x: 10, y: 10)
                    .frame(height: 50)
                   
                
                Text("Create New Group")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .shadow(color:Color(.sRGBLinear, red: 0.2, green: 0.2, blue: 0.2, opacity: 0.5), radius: 1, x: 0, y: 2)
                    .foregroundColor(Asset.Colors.Buttons.primaryButton.color)
                .modifier(ZcashButtonBackground(buttonShape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient))))
                
                    .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.5), radius: 25, x: 10, y: 10)
                    .frame(height: 50)
                
                Text("Month")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .shadow(color:Color(.sRGBLinear, red: 0.2, green: 0.2, blue: 0.2, opacity: 0.5), radius: 1, x: 0, y: 2)
                    .foregroundColor(Asset.Colors.Buttons.primaryButton.color)
                .modifier(ZcashButtonBackground(buttonShape: .roundedCorners(fillStyle: .gradient(gradient: LinearGradient.zButtonGradient))))
                .shadow(color:Asset.Colors.ProgressIndicator.gradientLeft.color.opacity(0.7), radius: 40, x: -25, y: 0)
                    .shadow(color:Asset.Colors.ProgressIndicator.gradientLeft.color.opacity(0.7), radius: 40, x: 25, y: 0)
                    .frame(width: 160, height: 80)
              
            }.padding([.horizontal, .bottom], 40)
        }
    }
}
