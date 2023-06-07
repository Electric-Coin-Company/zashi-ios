//
//  ExchangeStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

// TODO: [#315] Reimplement this into multicurrency supporter (https://github.com/zcash/secant-ios-wallet/issues/315)

public typealias CurrencySelectionStore = Store<CurrencySelectionReducer.State, CurrencySelectionReducer.Action>

public struct CurrencySelectionReducer: ReducerProtocol {
    public struct State: Equatable {
        public enum Currency: Equatable {
            case usd
            case zec

            public var acronym: String {
                switch self {
                case .usd:  return "USD"
                case .zec:  return "ZEC"
                }
            }
        }

        public var currencyType: Currency = .zec
        
        public init(currencyType: Currency = .zec) {
            self.currencyType = currencyType
        }
    }

    public enum Action: Equatable {
        case swapCurrencyType
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
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
