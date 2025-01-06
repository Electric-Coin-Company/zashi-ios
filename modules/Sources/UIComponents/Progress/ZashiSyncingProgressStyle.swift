//
//  ZashiSyncingProgressStyle.swift
//
//
//  Created by Lukáš Korba on 23.11.2023.
//

import SwiftUI
import Generated

public struct ZashiSyncingProgressStyle: ProgressViewStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = CGFloat(configuration.fractionCompleted ?? 0)

        Rectangle()
            .frame(width: 232, height: 14)
            .foregroundColor(Asset.Colors.shade85.color)
            .overlay {
                ZStack {
                    Rectangle()
                        .frame(width: 232 * fractionCompleted, height: 14)
                        .offset(x: -116 + (116 * fractionCompleted), y: 0)
                        .zForegroundColor(Design.Surfaces.brandBg)
                }
            }
    }
}
