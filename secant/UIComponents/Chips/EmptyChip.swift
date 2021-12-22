//
//  EmptyChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/22/21.
//

import SwiftUI

struct EmptyChip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: RoundedCornerStyle.continuous)
            .stroke(Asset.Colors.Text.activeButtonText.color, lineWidth: 0.5)
            .shadow(
                color: Asset.Colors.Text.activeButtonText.color,
                radius: -0.5,
                x: -0.1,
                y: -0.1
            )
            .innerShadow(
                using: RoundedRectangle(cornerRadius: 6, style: RoundedCornerStyle.continuous),
                angle: .degrees(180),
                color: Asset.Colors.Shadow.emptyChipInnerShadow.color,
                width: 4,
                blur: 2
            )
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 40,
                idealHeight: 40,
                maxHeight: .infinity,
                alignment: .leading
            )
    }
}

struct EmptyChip_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Asset.Colors.BackgroundColors.phraseGridDarkGray.color
                EmptyChip()
                    .frame(width: 100, height: 40, alignment: .leading)
            }
        }
        .previewLayout(.fixed(width: 200, height: 100))
        .preferredColorScheme(.light)

        Group {
            ZStack {
                EmptyChip()
                    .frame(width: 100, height: 40, alignment: .leading)
            }
            .applyScreenBackground()
        }
        .previewLayout(.fixed(width: 200, height: 100))
        .preferredColorScheme(.dark)
    }
}
