//
//  TransactionAmountTextField.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/4/22.
//

import SwiftUI
import ComposableArchitecture
import Generated

struct TransactionAmountTextField: View {
    let store: TransactionAmountTextFieldStore
    
    var body: some View {
        VStack {
            SingleLineTextField(
                placeholderText: L10n.Field.TransactionAmount.zecAmount(TargetConstants.tokenName),
                title: L10n.Field.TransactionAmount.amount,
                store: store.scope(
                    state: \.textFieldState,
                    action: TransactionAmountTextFieldReducer.Action.textField
                ),
                titleAccessoryView: { },
                inputPrefixView: { },
                inputAccessoryView: { }
            )
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
                        text: "".redacted
                    )
                ),
                reducer: TransactionAmountTextFieldReducer()
            )
        )
        .preferredColorScheme(.light)
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
                    label: { Text(L10n.General.max) }
                )
                .textFieldTitleAccessoryButtonStyle
            },
            inputPrefixView: { EmptyView() },
            inputAccessoryView: { EmptyView() }
        )
        .preferredColorScheme(.light)
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
        .preferredColorScheme(.light)
        .padding(.horizontal, 50)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 500, height: 200))
    }
}
