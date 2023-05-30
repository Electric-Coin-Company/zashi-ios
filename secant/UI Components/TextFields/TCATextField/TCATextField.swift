//
//  TextFieldInput.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/25/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

struct TCATextField: View {
    let placeholder: String
    let store: TCATextFieldStore

    var body: some View {
        WithViewStore(store) { viewStore in
            TextField(
                placeholder,
                text: Binding(
                    get: { viewStore.state.text.data },
                    set: { viewStore.send(.set($0.redacted)) }
                )
            )
            .autocapitalization(.none)
            .font(.system(size: 13))
            .lineLimit(1)
            .truncationMode(.middle)
            .accentColor(Asset.Colors.Cursor.bar.color)
        }
    }
}
