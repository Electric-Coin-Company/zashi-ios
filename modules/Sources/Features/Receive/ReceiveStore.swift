//
//  ReceiveStore.swift
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
import UIComponents
import Models

@Reducer
public struct Receive {
    @ObservableState
    public struct State: Equatable {
        public enum AddressType: Equatable {
            case saplingAddress
            case tAddress
            case uaAddress
        }

        public var currentFocus = AddressType.uaAddress
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil

        public var unifiedAddress: String {
            selectedWalletAccount?.uAddress?.stringEncoded ?? L10n.Receive.Error.cantExtractUnifiedAddress
        }

        public var saplingAddress: String {
            do {
                let address = try selectedWalletAccount?.uAddress?.saplingReceiver().stringEncoded ?? L10n.Receive.Error.cantExtractSaplingAddress
                return address
            } catch {
                return L10n.Receive.Error.cantExtractSaplingAddress
            }
        }

        public var transparentAddress: String {
            do {
                let address = try selectedWalletAccount?.uAddress?.transparentReceiver().stringEncoded ?? L10n.Receive.Error.cantExtractTransparentAddress
                return address
            } catch {
                return L10n.Receive.Error.cantExtractTransparentAddress
            }
        }

        public init() { }
    }

    public enum Action: Equatable {
        case addressDetailsRequest(RedactableString, Bool)
        case copyToPastboard(RedactableString)
        case requestTapped(RedactableString, Bool)
        case updateCurrentFocus(State.AddressType)
    }
    
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addressDetailsRequest:
                return .none
                
            case .copyToPastboard(let text):
                pasteboard.setString(text)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none

            case .requestTapped:
                return .none
                
            case .updateCurrentFocus(let newFocus):
                state.currentFocus = newFocus
                return .none
            }
        }
    }
}
