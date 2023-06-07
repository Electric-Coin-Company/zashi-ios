//
//  TextFieldFooter.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/25/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct TextFieldFooter: View {
    public var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Asset.Colors.TextField.Underline.purple.color)

            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(Asset.Colors.TextField.Underline.gray.color)
        }
    }
}
