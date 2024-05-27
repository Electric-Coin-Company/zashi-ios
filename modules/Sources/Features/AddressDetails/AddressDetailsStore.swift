//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import Generated
import Utils
import RequestPayment

@Reducer
public struct AddressDetails {
    @ObservableState
    public struct State: Equatable {
        public enum Selection: Equatable, Hashable, CaseIterable {
            case ua
            case transparent
        }
        
        public var addressToShare: RedactableString?
        public var requestPaymentState: RequestPayment.State
        public var requestPaymentViewBinding: Bool = false
        public var selection: Selection
        public var taQR: CGImage?
        public var uAddress: UnifiedAddress?
        public var uaQR: CGImage?

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
            requestPaymentState: RequestPayment.State,
            selection: Selection = .ua,
            uAddress: UnifiedAddress? = nil
        ) {
            self.addressToShare = addressToShare
            self.requestPaymentState = requestPaymentState
            self.selection = selection
            self.uAddress = uAddress
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<AddressDetails.State>)
        case copyToPastboard(RedactableString)
        case rememberQR(CGImage?, Bool)
        case requestPayment(RequestPayment.Action)
        case requestPaymentTapped
        case shareFinished
        case shareQR(RedactableString)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.requestPaymentState, action: /Action.requestPayment) {
            RequestPayment()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .rememberQR(image, uaQR):
                if uaQR {
                    state.uaQR = image
                } else {
                    state.taQR = image
                }
                return .none
                
            case .copyToPastboard(let text):
                pasteboard.setString(text)
                return .none
                
            case .requestPayment:
                return .none
                
            case .requestPaymentTapped:
                if state.selection == .transparent {
                    state.requestPaymentState.toAddress = state.transparentAddress
                    state.requestPaymentState.isMemoPossible = false
                } else {
                    state.requestPaymentState.toAddress = state.unifiedAddress
                    state.requestPaymentState.isMemoPossible = true
                }
                state.requestPaymentViewBinding = true
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
}
