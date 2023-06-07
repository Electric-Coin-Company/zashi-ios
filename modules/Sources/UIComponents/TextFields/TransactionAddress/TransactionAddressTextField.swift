//
//  TransactionAddressTextField.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct TransactionAddressTextField: View {
    let store: TransactionAddressTextFieldStore
    
    public init(store: TransactionAddressTextFieldStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                SingleLineTextField(
                    placeholderText: L10n.Field.TransactionAddress.validZcashAddress,
                    title: L10n.Field.TransactionAddress.to,
                    store: store.scope(
                        state: \.textFieldState,
                        action: TransactionAddressTextFieldReducer.Action.textField
                    ),
                    titleAccessoryView: { },
                    inputPrefixView: { },
                    inputAccessoryView: {
                        Button {
                            viewStore.send(.scanQR)
                        } label: {
                            Image(Asset.Assets.Icons.qrCode.name)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        .padding(.trailing, 10)
                    }
                )
            }
        }
    }
}

struct TransactionAddressTextField_Previews: PreviewProvider {
    static var previews: some View {
        TransactionAddressTextField(
            store: TransactionAddressTextFieldStore(
                initialState: .init(
                    textFieldState: .init(
                        validationType: .floatingPoint,
                        text: "".redacted
                    )
                ),
                reducer: TransactionAddressTextFieldReducer(networkType: .testnet)
            )
        )
        .preferredColorScheme(.light)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
