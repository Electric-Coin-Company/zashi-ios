//
//  ExchangeStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

typealias CurrencySelectionReducer = Reducer<
    CurrencySelectionState,
    CurrencySelectionAction,
    CurrencySelectionEnvironment
>

typealias CurrencySelectionStore = Store<CurrencySelectionState, CurrencySelectionAction>

struct CurrencySelectionState: Equatable {
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

enum CurrencySelectionAction: Equatable {
    case swapCurrencyType
}

struct CurrencySelectionEnvironment: Equatable { }

extension CurrencySelectionReducer {
    static var `default`: Self {
        .init { state, action, _ in
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
}
