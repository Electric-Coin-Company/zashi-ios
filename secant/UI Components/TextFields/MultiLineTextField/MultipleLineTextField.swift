//
//  MultipleLineTextField.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import SwiftUI
import ComposableArchitecture

struct MultipleLineTextField<TitleAccessoryContent>: View
    where TitleAccessoryContent: View {
    let store: MultiLineTextFieldStore
    let title: String

    @ViewBuilder let titleAccessoryView: TitleAccessoryContent

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text(title)
                        .font(.custom(FontFamily.Rubik.regular.name, size: 13))
                    Spacer()
                    titleAccessoryView
                }
                
                TextEditor(text: viewStore.binding(\.$text))
                    .multilineTextEditorModifier(
                        Asset.Colors.Text.activeButtonText.color,
                        Asset.Colors.TextField.multilineOutline.color
                    )
                
                if viewStore.isCharLimited {
                    HStack {
                        Spacer()
                        Text(viewStore.charLimitText)
                            .font(.custom(FontFamily.Rubik.regular.name, size: 14))
                            .foregroundColor(
                                viewStore.isValid
                                ? Asset.Colors.TextField.multilineOutline.color
                                : Asset.Colors.Text.invalidEntry.color
                            )
                    }
                }
            }
        }
        .onAppear(perform: { UITextView.appearance().backgroundColor = .clear })
    }
}

struct MultilineTextEditorModifier: ViewModifier {
    var backgroundColor = Color.white
    var outlineColor = Color.black

    func body(content: Content) -> some View {
        content
            .foregroundColor(Asset.Colors.Text.importSeedEditor.color)
            .padding()
            .background(backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(outlineColor, lineWidth: 2)
            )
    }
}

extension View {
    func multilineTextEditorModifier(
        _ backgroundColor: Color = .white,
        _ outlineColor: Color = .black
    ) -> some View {
        modifier(
            MultilineTextEditorModifier(
                backgroundColor: backgroundColor,
                outlineColor: outlineColor
            )
        )
    }
}

struct MultipleLineTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultipleLineTextField(
            store: .placeholder,
            title: "Memo",
            titleAccessoryView: {
                Text("accessory")
                    .font(.custom(FontFamily.Rubik.regular.name, size: 13))
            }
        )
        .frame(height: 200)
        .padding()
        .applyScreenBackground()
        .preferredColorScheme(.dark)
    }
}
