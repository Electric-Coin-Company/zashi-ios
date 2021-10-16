//
//  ZcashButton.swift
//  wallet
//
//  Created by Francisco Gindre on 12/30/19.
//  Copyright © 2019 Francisco Gindre. All rights reserved.
//

import SwiftUI

struct ZcashButton: View {
    
    enum BackgroundShape {
        case chamfered
        case rounded
        case roundedCorners
    }
    var buttonShape: BackgroundShape = .chamfered
    var color = Color.yellow
    var fill = Color.black
    var text: String
    
    func backgroundWith(geometry: GeometryProxy, backgroundShape: BackgroundShape) -> AnyView {
        
        switch backgroundShape {
        case .chamfered:
            
            return AnyView (
                Group {
                ZcashChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                    .fill(self.fill)
                
                ZcashChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                    .stroke(self.color, lineWidth: 1.0)
                }
            )
        case .rounded:
            return AnyView(
                EmptyView()
            )
        case .roundedCorners:
            return AnyView(
                EmptyView()
            )
        }
    }
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                self.backgroundWith(geometry: geometry, backgroundShape: self.buttonShape)
            }
            Text(self.text)
                .foregroundColor(self.color)
                .font(.body)
            
        }.frame(minWidth: 30, idealWidth: 30, minHeight: 30, idealHeight: 30)
    }
}


struct ZcashRoundCorneredButtonBackground: Shape {
    var cornerRadius: CGFloat = 12
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}

struct ZcashRoundedButtonBackground: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: rect.height).path(in: rect)
    }
}

struct ZcashChamferedButtonBackground: Shape {
    var cornerTrim: CGFloat
    func path(in rect: CGRect) -> Path {
        
        Path {
            path in
            
            path.move(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top border
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: cornerTrim
                )
            )
            
            // right border
            
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: rect.height - cornerTrim
                )
            )
            
            // bottom right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom border
            
            path.addLine(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom left lip
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.height - cornerTrim
                )
            )
            
            // left border
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: cornerTrim
                )
            )
            
            // top left lip
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x + cornerTrim,
                    y: rect.origin.y
                )
            )
        }
    }
}

struct ZcashButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                ZcashButton(color: Asset.Colors.Text.button.color, fill: Color.clear, text: "Create New Wallet")
                .frame(width: 300, height: 60)
            
                ZcashButton(color: .black, fill: Color.clear, text: "Create New Wallet")
                .frame(width: 300, height: 60)
            }
        }
    }
}
