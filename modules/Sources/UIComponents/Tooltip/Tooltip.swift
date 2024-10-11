//
//  Tooltip.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-06-2024.
//

import SwiftUI

import Generated

public struct Tooltip: View {
    public var onTapGesture: () -> Void
    public var title: String
    public var desc: String
    public var bottomMode: Bool
    
    public init(
        title: String,
        desc: String,
        bottomMode: Bool = false,
        onTapGesture: @escaping () -> Void
    ) {
        self.title = title
        self.desc = desc
        self.bottomMode = bottomMode
        self.onTapGesture = onTapGesture
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if !bottomMode {
                Asset.Assets.tooltip.image
                    .zImage(width: 16, height: 6, style: Design.HintTooltips.surfacePrimary)
                    .offset(x: 0, y: 2)
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                        .foregroundColor(Design.Text.light.color)
                        .padding(.bottom, 4)
                    
                    Text(desc)
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(Design.Text.lightSupport.color)
                        .lineLimit(nil)
                        .lineSpacing(1.5)
                }
                
                Asset.Assets.buttonCloseX.image
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Design.HintTooltips.defaultFg.color)
            }
            .padding(12)
            .background(Design.HintTooltips.surfacePrimary.color)
            .cornerRadius(8)
            // TODO: Colors from Design once available
            .shadow(color: Color(red: 0.137, green: 0.122, blue: 0.125).opacity(0.03), radius: 4, x: 0, y: 4)
            .shadow(color: Color(red: 0.137, green: 0.122, blue: 0.125).opacity(0.08), radius: 8, x: 0, y: 12)
            
            if bottomMode {
                Asset.Assets.tooltip.image
                    .zImage(width: 16, height: 6, style: Design.HintTooltips.surfacePrimary)
                    .rotationEffect(Angle(degrees: 180))
                    .offset(x: 0, y: -2)
            }
        }
        .onTapGesture { onTapGesture() }
    }
}
