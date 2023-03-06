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
                    placeholderText: "Valid Zcash Address",
                    title: "To:",
                    store: store.scope(
                        state: \.textFieldState,
                        action: TransactionAddressTextFieldReducer.Action.textField
                    ),
                    titleAccessoryView: {
                        if !viewStore.textFieldState.text.data.isEmpty {
                            Button(
                                action: {
                                    viewStore.send(.clearAddress)
                                },
                                label: {
                                    Text(L10n.General.clear)
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
                reducer: TransactionAddressTextFieldReducer()
            )
        )
        .preferredColorScheme(.light)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
