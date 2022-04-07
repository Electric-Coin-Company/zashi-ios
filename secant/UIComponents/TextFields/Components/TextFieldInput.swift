//
//  TextFieldInput.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/25/22.
//

import SwiftUI
import ComposableArchitecture

struct TextFieldInput: View {
    let placeholder: String
    let store: TextFieldStore

    var body: some View {
        WithViewStore(store) { viewStore in
            TextField(
                placeholder,
                text: Binding(
                    get: { viewStore.state.text },
                    set: { viewStore.send(.set($0)) }
                )
            )
            .lineLimit(1)
            .truncationMode(.middle)
            .accentColor(Asset.Colors.Cursor.bar.color)
        }
    }
}
