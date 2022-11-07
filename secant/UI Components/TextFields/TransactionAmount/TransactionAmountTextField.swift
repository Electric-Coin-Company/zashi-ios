//
//  TransactionAmountTextField.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/4/22.
//

import SwiftUI
import ComposableArchitecture

struct TransactionAmountTextField: View {
    let store: TransactionAmountTextFieldStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                SingleLineTextField(
                    placeholderText: "0",
                    title: "How much ZEC would you like to send?",
                    store: store.scope(
                        state: \.textFieldState,
                        action: TransactionAmountTextFieldReducer.Action.textField
                    ),
                    titleAccessoryView: {
                        Button(
                            action: {
                                viewStore.send(viewStore.isMax ? .clearValue : .setMax)
                            },
                            label: {
                                Text(viewStore.isMax ? "Clear" : "Max")
                            }
                        )
                        .textFieldTitleAccessoryButtonStyle
                    },
                    inputPrefixView: {
                        if viewStore.currencySelectionState.currencyType == .zec {
                            ZcashSymbol()
                                .frame(width: 12, height: 12, alignment: .center)
                        } else {
                            Text("$")
                        }
                    },
                    inputAccessoryView: {
                        CurrencySelectionView(
                            store: store.scope(
                                state: \.currencySelectionState,
                                action: TransactionAmountTextFieldReducer.Action.currencySelection
                            )
                        )
                    }
                )
            }
        }
    }
}

struct TransactionAmountTextField_Previews: PreviewProvider {
    static var previews: some View {
        TransactionAmountTextField(
            store: TransactionAmountTextFieldStore(
                initialState: .init(
                    currencySelectionState: .init(currencyType: .usd),
                    textFieldState: .init(
                        validationType: .floatingPoint,
                        text: ""
                    )
                ),
                reducer: TransactionAmountTextFieldReducer()
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
            inputPrefixView: { EmptyView() },
            inputAccessoryView: { EmptyView() }
        )
        .preferredColorScheme(.dark)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))

        SingleLineTextField(
            placeholderText: "",
            title: "Address",
            store: .address,
            titleAccessoryView: { EmptyView() },
            inputPrefixView: { EmptyView() },
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
