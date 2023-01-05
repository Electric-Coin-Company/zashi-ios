//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

typealias AddressDetailsStore = Store<AddressDetailsReducer.State, AddressDetailsReducer.Action>

struct AddressDetailsReducer: ReducerProtocol {
    struct State: Equatable {
        var uAddress: UnifiedAddress?

        var unifiedAddress: String {
            uAddress?.stringEncoded ?? "could not extract UA"
        }

        var transparentAddress: String {
            uAddress?.transparentReceiver()?.stringEncoded ?? "could not extract transparent receiver from UA"
        }

        var saplingAddress: String {
            uAddress?.saplingReceiver()?.stringEncoded ?? "could not extract sapling receiver from UA"
        }
    }

    enum Action: Equatable {
        case copySaplingAddressToPastboard
        case copyTransparentAddressToPastboard
        case copyUnifiedAddressToPastboard
    }
    
    @Dependency(\.pasteboard) var pasteboard
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .copySaplingAddressToPastboard:
            pasteboard.setString(state.saplingAddress)
        case .copyTransparentAddressToPastboard:
            pasteboard.setString(state.transparentAddress)
        case .copyUnifiedAddressToPastboard:
            pasteboard.setString(state.unifiedAddress)
        }
        return .none
    }
}

// MARK: - Placeholders

extension AddressDetailsReducer.State {
    static let placeholder = AddressDetailsReducer.State()
}

extension AddressDetailsStore {
    static let placeholder = AddressDetailsStore(
        initialState: .placeholder,
        reducer: AddressDetailsReducer()
    )
}
