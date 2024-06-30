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
import ZcashPaymentURI

@Reducer
public struct RequestPayment {
    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var encryptedOutput: String?
        public var isMemoPossible: Bool
        public var isValidInput: Bool
        public var memoState: MessageEditorReducer.State
        public var toAddress: String
        public var zecAmountText: String

        public var isInvalidAmount: Bool {
            @Dependency(\.numberFormatter) var numberFormatter

            guard let amount = numberFormatter.number(zecAmountText),
                  let _ = try? Amount(decimal: amount.decimalValue) else {
                return !zecAmountText.isEmpty
            }
            
            return !isValidInput
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
        case alert(PresentationAction<Action>)
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
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .binding:
                state.isValidInput = numberFormatter.number(state.zecAmountText) != nil
                return .none
                
            case .memo:
                return .none
                
            case .shareFinished:
                state.encryptedOutput = nil
                return .none
                
            case .shareQRCodeTapped:
                if let recipient = RecipientAddress(value: state.toAddress) {
                    do {
                        guard let amount = numberFormatter.number(state.zecAmountText) else {
                            return .none
                        }
                        
                        let payment = Payment(
                            recipientAddress: recipient,
                            amount: try Amount(decimal: amount.decimalValue),
                            memo: try MemoBytes(utf8String: state.memoState.text.data),
                            label: nil,
                            message: nil,
                            otherParams: nil
                        )
                        
                        state.encryptedOutput = ZIP321.request(payment, formattingOptions: .useEmptyParamIndex(omitAddressLabel: true))
                    } catch {
                        state.alert = AlertState.paymentInitFailure(error)
                        return .none
                    }
                }
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == RequestPayment.Action {
    public static func paymentInitFailure(_ error: Error) -> AlertState {
        AlertState {
            TextState("Zashi Me failed")
        } message: {
            TextState("The format of the input is invalid, specifically: \(error.localizedDescription)")
        }
    }
}
