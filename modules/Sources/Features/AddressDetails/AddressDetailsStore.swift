//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import Generated

public typealias AddressDetailsStore = Store<AddressDetailsReducer.State, AddressDetailsReducer.Action>

public struct AddressDetailsReducer: ReducerProtocol {
    public struct State: Equatable {
        public var uAddress: UnifiedAddress?

        public var unifiedAddress: String {
            uAddress?.stringEncoded ?? L10n.AddressDetails.Error.cantExtractUnifiedAddress
        }

        public var transparentAddress: String {
            do {
                let address = try uAddress?.transparentReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractTransparentAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractTransparentAddress
            }
        }

        public var saplingAddress: String {
            do {
                let address = try uAddress?.saplingReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractSaplingAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractSaplingAddress
            }
        }
        
        public init(uAddress: UnifiedAddress? = nil) {
            self.uAddress = uAddress
        }
    }

    public enum Action: Equatable {
        case copySaplingAddressToPastboard
        case copyTransparentAddressToPastboard
        case copyUnifiedAddressToPastboard
    }
    
    @Dependency(\.pasteboard) var pasteboard
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
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
    public static let placeholder = AddressDetailsReducer.State()
}

extension AddressDetailsStore {
    public static let placeholder = AddressDetailsStore(
        initialState: .placeholder,
        reducer: AddressDetailsReducer()
    )
}
