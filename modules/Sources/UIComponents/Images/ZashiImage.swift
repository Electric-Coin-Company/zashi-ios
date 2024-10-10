//
//  ZashiImage.swift
//  Zashi
//
//  Created by Lukáš Korba on 16.09.2024.
//

import SwiftUI

import Generated

public extension Image {
    func zImage(
        width: CGFloat,
        height: CGFloat,
        style: Colorable
    ) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .frame(width: width, height: height)
            .foregroundColor(style.color)
    }
    
    func zImage(
        width: CGFloat,
        height: CGFloat,
        color: Color
    ) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .frame(width: width, height: height)
            .foregroundColor(color)
    }
    
    func zImage(
        size: CGFloat,
        style: Colorable
    ) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .frame(width: size, height: size)
            .foregroundColor(style.color)
    }
    
    func zImage(
        size: CGFloat,
        color: Color
    ) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
}
