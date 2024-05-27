//
//  RequestPaymentStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-24-2024
//

import Foundation
import ComposableArchitecture

import Generated
import Models
import UIComponents
import Utils
import ZcashLightClientKit
import NumberFormatter

@Reducer
public struct RequestPayment {
    @ObservableState
    public struct State: Equatable {
        public var encryptedOutput: String?
        public var isMemoPossible: Bool
        public var isValidInput: Bool
        public var memoState: MessageEditorReducer.State
        public var toAddress: String
        public var zecAmountText: String

        public var isInvalidAmount: Bool {
            !zecAmountText.isEmpty
            && !isValidInput
        }
        
        public init(
            encryptedOutput: String? = nil,
            isMemoPossible: Bool = true,
            isValidInput: Bool = false,
            memoState: MessageEditorReducer.State,
            toAddress: String,
            zecAmountText: String = ""
        ) {
            self.encryptedOutput = encryptedOutput
            self.isMemoPossible = isMemoPossible
            self.isValidInput = isValidInput
            self.memoState = memoState
            self.toAddress = toAddress
            self.zecAmountText = zecAmountText
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<RequestPayment.State>)
        case memo(MessageEditorReducer.Action)
        case shareFinished
        case shareQRCodeTapped
    }

    public init() { }

    @Dependency(\.numberFormatter) var numberFormatter

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.memoState, action: /Action.memo) {
            MessageEditorReducer()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                state.isValidInput = numberFormatter.number(state.zecAmountText) != nil
                return .none
                
            case .memo:
                return .none
                
            case .shareFinished:
                state.encryptedOutput = nil
                return .none
                
            case .shareQRCodeTapped:
                // encrypt the data
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .binary
                if let data = try? encoder.encode(RPData(address: state.toAddress, ammount: state.zecAmountText, memo: state.memoState.text.data)) {
                    state.encryptedOutput = data.base64EncodedString()
                }
                return .none
            }
        }
    }
}
