//
//  TransactionAddressTextField.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import SwiftUI
import ComposableArchitecture

struct TransactionAddressTextField: View {
    let store: TransactionAddressTextFieldStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                SingleLineTextField(
                    placeholderText: "address",
                    title: "To",
                    store: store.scope(
                        state: \.textFieldState,
                        action: TransactionAddressTextFieldReducer.Action.textField
                    ),
                    titleAccessoryView: {
                        if !viewStore.textFieldState.text.isEmpty {
                            Button(
                                action: {
                                    viewStore.send(.clearAddress)
                                },
                                label: {
                                    Text("Clear")
                                }
                            )
                            .textFieldTitleAccessoryButtonStyle
                        }
                    },
                    inputPrefixView: { EmptyView() },
                    inputAccessoryView: {
                        Button {
                            viewStore.send(.scanQR)
                        } label: {
                            Image(Asset.Assets.Icons.qrCode.name)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
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
                        text: ""
                    )
                ),
                reducer: TransactionAddressTextFieldReducer()
            )
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
