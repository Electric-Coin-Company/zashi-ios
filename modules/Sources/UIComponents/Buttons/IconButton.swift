//
//  SwiftUIView.swift
//  
//
//  Created by Lukáš Korba on 29.05.2024.
//

import SwiftUI

import Generated

public struct IconButton<Content: View>: View {
    let title: String
    let action: () -> Void
    let content: () -> Content

    public init(title: String, _ action: @escaping () -> Void, content: @escaping () -> Content) {
        self.title = title
        self.action = action
        self.content = content
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(Asset.Colors.primary.color)
                        .frame(width: 50, height: 50)
                    
                    content()
                }
                .padding(.bottom, 10)

                Text(title)
                    .font(.custom(FontFamily.Inter.bold.name, size: 12))
                    .foregroundColor(Asset.Colors.primary.color)
            }
        }
        .padding(10)
    }
}

#Preview {
    IconButton(title: "Copy") {
        
    } content: {
        Asset.Assets.copy.image
    }
}
