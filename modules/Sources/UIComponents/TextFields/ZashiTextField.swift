//
//  ZashiTextField.swift
//
//
//  Created by Lukáš Korba on 22.05.2024.
//

import SwiftUI

import Generated

public struct ZashiTextField<PrefixContent, AccessoryContent>: View where PrefixContent: View, AccessoryContent: View {
    var text: Binding<String>
    var placeholder: String
    var title: String?
    var error: String?
    
    @ViewBuilder let accessoryView: AccessoryContent?
    @ViewBuilder let prefixView: PrefixContent?

    public init(
        text: Binding<String>,
        placeholder: String = "",
        title: String? = nil,
        error: String? = nil,
        accessoryView: AccessoryContent? = EmptyView(),
        prefixView: PrefixContent? = EmptyView()
    ) {
        self.text = text
        self.placeholder = placeholder
        self.title = title
        self.error = error
        self.accessoryView = accessoryView
        self.prefixView = prefixView
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                Text(title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.custom(FontFamily.Inter.medium.name, size: 14))
                    .foregroundColor(Design.Inputs.Filled.label.color)
                    .padding(.bottom, 6)
            }
            
            HStack(spacing: 0) {
                if let prefixView {
                    prefixView
                        .padding(.trailing, 8)
                }

                TextField(
                    "",
                    text: text,
                    prompt:
                        Text(placeholder)
                            .font(.custom(FontFamily.Inter.regular.name, size: 16))
                            .foregroundColor(Design.Inputs.Default.text.color)
                )
                .autocapitalization(.none)
                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                .lineLimit(1)
                .truncationMode(.middle)
                .accentColor(Asset.Colors.primary.color)
                
                Spacer()
                
                if let accessoryView {
                    accessoryView
                        .padding(.leading, 8)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Design.Inputs.Default.bg.color)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                error == nil
                                ? Design.Inputs.Default.bg.color
                                : Design.Inputs.ErrorFilled.stroke.color
                            )
                    }
            )

            if let error {
                Text(error)
                    .foregroundColor(Design.Inputs.ErrorFilled.hint.color)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .padding(.top, 6)
            }
        }
    }
}

#Preview {
    @State var text = ""
    return VStack(spacing: 30) {
        ZashiTextField(
            text: $text,
            placeholder: "Placeholder"
        )

        ZashiTextField(
            text: $text,
            placeholder: "ZEC",
            title: "Amount",
            prefixView:
                ZcashSymbol()
                    .frame(width: 12, height: 20)
                    .foregroundColor(Design.Inputs.Default.text.color)
        )

        ZashiTextField(
            text: $text,
            placeholder: "Placeholder",
            title: "Title",
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Inputs.Default.text),
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Inputs.Default.text)
        )

        ZashiTextField(
            text: $text,
            placeholder: "Placeholder",
            title: "Title",
            error: "This contact name exceeds the 32-character limit. Please shorten the name.",
            accessoryView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Inputs.Default.text),
            prefixView:
                Asset.Assets.Icons.key.image
                    .zImage(size: 20, style: Design.Inputs.Default.text)
        )
    }
    .padding()
}
