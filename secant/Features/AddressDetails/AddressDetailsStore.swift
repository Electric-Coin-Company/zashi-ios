//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import PasteboardClient
import Generated

typealias AddressDetailsStore = Store<AddressDetailsReducer.State, AddressDetailsReducer.Action>

struct AddressDetailsReducer: ReducerProtocol {
    struct State: Equatable {
        var uAddress: UnifiedAddress?

        var unifiedAddress: String {
            uAddress?.stringEncoded ?? L10n.AddressDetails.Error.cantExtractUnifiedAddress
        }

        var transparentAddress: String {
            do {
                let address = try uAddress?.transparentReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractTransparentAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractTransparentAddress
            }
        }

        var saplingAddress: String {
            do {
                let address = try uAddress?.saplingReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractSaplingAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractSaplingAddress
            }
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
            pasteboard.setString(state.saplingAddress.redacted)
        case .copyTransparentAddressToPastboard:
            pasteboard.setString(state.transparentAddress.redacted)
        case .copyUnifiedAddressToPastboard:
            pasteboard.setString(state.unifiedAddress.redacted)
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
