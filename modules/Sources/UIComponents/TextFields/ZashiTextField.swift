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
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .foregroundColor(Asset.Colors.primary.color)
            }
            
            HStack(spacing: 0) {
                if let prefixView {
                    prefixView
                }

                TextField(
                    "",
                    text: text,
                    prompt: Text(placeholder).foregroundColor(Asset.Colors.shade72.color)
                )
                .autocapitalization(.none)
                .font(.custom(FontFamily.Archivo.regular.name, size: 14))
                .lineLimit(1)
                .truncationMode(.middle)
                .accentColor(Asset.Colors.primary.color)
                .padding(10)
                .frame(height: 40)
                
                Spacer()
                
                if let accessoryView {
                    accessoryView
                }
            }
            .overlay(
                Rectangle()
                    .stroke(Asset.Colors.primary.color, lineWidth: 1)
            )

            if let error {
                Text(error)
                    .foregroundColor(Design.Utility.ErrorRed._600.color)
                    .font(.custom(FontFamily.Inter.medium.name, size: 12))
            }
        }
    }
}

#Preview {
    @State var text = ""
    return ZashiTextField(text: $text)
}
