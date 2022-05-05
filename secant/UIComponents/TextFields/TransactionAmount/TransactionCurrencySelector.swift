//
//  TransactionCurrencySelector.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/4/22.
//

import SwiftUI
import ComposableArchitecture

struct TransactionCurrencySelector: View {
    let store: CurrencySelectionStore

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(.swapCurrencyType) },
                label: {
                    HStack {
                        Text(CurrencySelectionState.Currency.usd.acronym)
                            .foregroundColor(
                                viewStore.currencyType == .usd ? .yellow : .white
                            )

                        Asset.Assets.Icons.swap.image

                        Text(CurrencySelectionState.Currency.zec.acronym)
                            .foregroundColor(
                                viewStore.currencyType == .zec ? .yellow : .white
                            )
                    }
                }
            )
        }
    }
}
