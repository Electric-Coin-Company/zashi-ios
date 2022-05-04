//
//  TransactionTextField.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/4/22.
//

import SwiftUI
import ComposableArchitecture

struct TransactionTextField: View {
    let store: TransactionInputStore

    // Constant example used here, this could be injected by a dependency
    // Access to this value could also be injected into the store as a dependency
    // with a function to prouce this value.
    let maxTransactionValue: Int64 = 500

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                SingleLineTextField(
                    placeholderText: "$0",
                    title: "How much?",
                    store: store.scope(
                        state: \.textFieldState,
                        action: TransactionInputAction.textField
                    ),
                    titleAccessoryView: {
                        Button(
                            action: {
                                viewStore.send(.setMax(maxTransactionValue))
                            },
                            label: { Text("Max") }
                        )
                        .textFieldTitleAccessoryButtonStyle
                    },
                    inputAccessoryView: {
                        TransactionCurrencySelector(
                            store: store.scope(
                                state: \.currencySelectionState,
                                action: TransactionInputAction.currencySelection
                            )
                        )
                    }
                )
            }
        }
    }
}

struct TransactionTextField_Previews: PreviewProvider {
    static var previews: some View {
        TransactionTextField(
            store: TransactionInputStore(
                initialState: .init(
                    textFieldState: .init(
                        validationType: .floatingPoint,
                        text: ""
                    ),
                    currencySelectionState: .init(currencyType: .usd)
                ),
                reducer: .default,
                environment: .init()
            )
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
        
        SingleLineTextField(
            placeholderText: "$0",
            title: "How much?",
            store: .transaction,
            titleAccessoryView: {
                Button(
                    action: { },
                    label: { Text("Max") }
                )
                .textFieldTitleAccessoryButtonStyle
            },
            inputAccessoryView: {
            }
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))

        SingleLineTextField(
            placeholderText: "",
            title: "Address",
            store: .address,
            titleAccessoryView: {
            },
            inputAccessoryView: {
                Image(Asset.Assets.Icons.qrCode.name)
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
