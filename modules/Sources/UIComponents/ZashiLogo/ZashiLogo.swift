//
//  ZashiLogo.swift
//
//
//  Created by Lukáš Korba on 16.10.2023.
//

import SwiftUI
import Generated

public struct ZashiIcon: View {
    public init() { }
    
    public var body: some View {
        Asset.Assets.zashiLogo.image
            .resizable()
            .renderingMode(.template)
            .tint(Asset.Colors.primary.color)
            .frame(width: 33, height: 43)
            .padding(.bottom, 30)
    }
}

public struct ZashiErrorIcon: View {
    public init() { }
    
    public var body: some View {
        ZashiIcon()
            .padding(.top, 20)
            .scaleEffect(2)
            .padding(.vertical, 30)
            .overlay {
                Asset.Assets.alertIcon.image
                    .resizable()
                    .frame(width: 24, height: 24)
                    .offset(x: 25, y: 15)
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        ZashiIcon()

        ZashiErrorIcon()
    }
}
