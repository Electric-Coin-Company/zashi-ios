//
//  ExchangeStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

// TODO: [#315] Reimplement this into multicurrency supporter (https://github.com/zcash/secant-ios-wallet/issues/315)

typealias CurrencySelectionStore = Store<CurrencySelectionReducer.State, CurrencySelectionReducer.Action>

struct CurrencySelectionReducer: ReducerProtocol {
    struct State: Equatable {
        enum Currency: Equatable {
            case usd
            case zec

            var acronym: String {
                switch self {
                case .usd:  return "USD"
                case .zec:  return "ZEC"
                }
            }
        }

        var currencyType: Currency = .zec
    }

    enum Action: Equatable {
        case swapCurrencyType
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .swapCurrencyType:
            switch state.currencyType {
            case .usd:  state.currencyType = .zec
            case .zec:  state.currencyType = .usd
            }
        }
        return .none
    }
}
