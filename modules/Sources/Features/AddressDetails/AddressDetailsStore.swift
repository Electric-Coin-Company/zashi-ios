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
import Utils

public typealias AddressDetailsStore = Store<AddressDetailsReducer.State, AddressDetailsReducer.Action>
public typealias AddressDetailsViewStore = ViewStore<AddressDetailsReducer.State, AddressDetailsReducer.Action>

public struct AddressDetailsReducer: Reducer {
    public struct State: Equatable {
        public var addressToShare: RedactableString?
        public var uAddress: UnifiedAddress?

        public var unifiedAddress: String {
            uAddress?.stringEncoded ?? L10n.AddressDetails.Error.cantExtractUnifiedAddress
        }

        public var saplingAddress: String {
            do {
                let address = try uAddress?.saplingReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractSaplingAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractSaplingAddress
            }
        }

        public var transparentAddress: String {
            do {
                let address = try uAddress?.transparentReceiver().stringEncoded ?? L10n.AddressDetails.Error.cantExtractTransparentAddress
                return address
            } catch {
                return L10n.AddressDetails.Error.cantExtractTransparentAddress
            }
        }

        public init(
            addressToShare: RedactableString? = nil,
            uAddress: UnifiedAddress? = nil
        ) {
            self.addressToShare = addressToShare
            self.uAddress = uAddress
        }
    }

    public enum Action: Equatable {
        case copyToPastboard(RedactableString)
        case shareFinished
        case shareQR(RedactableString)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
        case .copyToPastboard(let text):
            pasteboard.setString(text)
            return .none
        
        case .shareFinished:
            state.addressToShare = nil
            return .none

        case .shareQR(let text):
            state.addressToShare = text
            return .none
        }
    }
}

// MARK: - Placeholders

extension AddressDetailsReducer.State {
    public static let initial = AddressDetailsReducer.State()
    
    public static let demo = AddressDetailsReducer.State(
        uAddress: try! UnifiedAddress(
            encoding: "utest1vergg5jkp4xy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzjanqtl8uqp5vln3zyy246ejtx86vqftp73j7jg9099jxafyjhfm6u956j3",
            network: .testnet)
    )
}

extension AddressDetailsStore {
    public static let placeholder = AddressDetailsStore(
        initialState: .initial
    ) {
        AddressDetailsReducer()
    }
}
