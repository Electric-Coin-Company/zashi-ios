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

#Preview {
    ZashiIcon()
}
