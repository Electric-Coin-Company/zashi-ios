//
//  CurrencySelectionView.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/4/22.
//

import SwiftUI
import ComposableArchitecture

public struct CurrencySelectionView: View {
    let store: CurrencySelectionStore

    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(.swapCurrencyType) },
                label: {
                    HStack {
                        Text(CurrencySelectionReducer.State.Currency.usd.acronym)
                            .foregroundColor(
                                viewStore.currencyType == .usd ? .yellow : .white
                            )

                        Text(CurrencySelectionReducer.State.Currency.zec.acronym)
                            .foregroundColor(
                                viewStore.currencyType == .zec ? .yellow : .white
                            )
                    }
                }
            )
        }
    }
}
