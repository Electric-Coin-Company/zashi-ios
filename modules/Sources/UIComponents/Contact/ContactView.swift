//
//  ContactView.swift
//
//
//  Created by Lukáš Korba on 09.09.2024.
//

import SwiftUI
import Generated

public struct ContactView: View {
    var iconText: String
    var title: String
    var desc: String?
    var action: () -> Void
    
    public init(
        iconText: String,
        title: String,
        desc: String? = nil,
        action: @escaping () -> Void
    ) {
        self.iconText = iconText
        self.title = title
        self.desc = desc
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(iconText)
                        .minimumScaleFactor(0.5)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 14))
                        .foregroundColor(Design.Avatars.textFg.color)
                        .frame(width: 20, height: 20)
                        .padding(10)
                        .background {
                            Circle()
                                .fill(Design.Avatars.bg.color)
                        }
                        .padding(.trailing, 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 14))
                            .foregroundColor(Design.Text.primary.color)
                        
                        if let desc {
                            Text(desc)
                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                .foregroundColor(Design.Text.tertiary.color)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.trailing, 16)
                    
                    Spacer(minLength: 2)
                    
                    Asset.Assets.chevronRight.image
                        .zImage(size: 20, style: Design.Text.tertiary)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 12)
    }
}

#Preview {
    ContactView(
        iconText: "LK",
        title: "test",
        action: { }
    )
}
