//
//  SendFlowStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import Utils
import Scan
import SDKSynchronizer
import ZcashSDKEnvironment
import UIComponents
import Models
import Generated
import BalanceFormatter
import WalletBalances
import AddressBookClient

public typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
public typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

public struct SendFlowReducer: Reducer {
    public enum Confirmation: Equatable {
        case requestPayment
        case send
    }

    public struct State: Equatable {
        public enum Destination: Equatable {
            case partialProposalError
            case scanQR
        }

        @PresentationState public var alert: AlertState<Action>?
        public var addMemoState: Bool
        public var destination: Destination?
        public var memoState: MessageEditorReducer.State
        public var proposal: Proposal?
        public var scanState: Scan.State
        public var shieldedBalance: Zatoshi
        public var transactionAddressInputState: TransactionAddressTextFieldReducer.State
        public var transactionAmountInputState: TransactionAmountTextFieldReducer.State
        public var walletBalancesState: WalletBalances.State

        public var address: String {
            get { transactionAddressInputState.textFieldState.text.data }
            set { transactionAddressInputState.textFieldState.text = newValue.redacted }
        }

        public var amount: Zatoshi {
            get { Zatoshi(transactionAmountInputState.amount.data) }
            set {
                transactionAmountInputState.amount = newValue.amount.redacted
                transactionAmountInputState.textFieldState.text = newValue.amount == 0 ?
                "".redacted :
                newValue.decimalString().redacted
            }
        }

        public var feeFormat: String {
            "(\(ZatoshiStringRepresentation.feeFormat))"
        }

        public var feeRequired: Zatoshi {
            proposal?.totalFeeRequired() ?? Zatoshi(0)
        }

        public var message: String {
            memoState.text.data
        }

        public var isInvalidAddressFormat: Bool {
            !transactionAddressInputState.textFieldState.text.data.isEmpty
            && !transactionAddressInputState.isValidAddress
        }

        public var isInvalidAmountFormat: Bool {
            !transactionAmountInputState.textFieldState.text.data.isEmpty
            && !transactionAmountInputState.isValidInput
        }
        
        public var isValidForm: Bool {
            transactionAddressInputState.isValidAddress
            && !isInsufficientFunds
            && memoState.isValid
            && transactionAmountInputState.isValidInput
        }

        public var isInsufficientFunds: Bool {
            guard transactionAmountInputState.isValidInput else { return false }

            return transactionAmountInputState.amount.data > shieldedBalance.amount
        }
        
        public var isMemoInputEnabled: Bool {
            !transactionAddressInputState.isValidTransparentAddress
        }
        
        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
        
        public var spendableBalanceString: String {
            shieldedBalance.decimalString(formatter: NumberFormatter.zashiBalanceFormatter)
        }
        
        public init(
            addMemoState: Bool,
            destination: Destination? = nil,
            memoState: MessageEditorReducer.State,
            scanState: Scan.State,
            shieldedBalance: Zatoshi = .zero,
            transactionAddressInputState: TransactionAddressTextFieldReducer.State,
            transactionAmountInputState: TransactionAmountTextFieldReducer.State,
            walletBalancesState: WalletBalances.State
        ) {
            self.addMemoState = addMemoState
            self.destination = destination
            self.memoState = memoState
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.transactionAddressInputState = transactionAddressInputState
            self.transactionAmountInputState = transactionAmountInputState
            self.walletBalancesState = walletBalancesState
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case confirmationRequired(Confirmation)
        case getProposal(Confirmation)
        case insufficientFundsForRP
        case memo(MessageEditorReducer.Action)
        case onAppear
        case proposal(Proposal)
        case resetForm
        case reviewPressed
        case scan(Scan.Action)
        case sendFailed(ZcashError)
        case transactionAddressInput(TransactionAddressTextFieldReducer.Action)
        case transactionAmountInput(TransactionAmountTextFieldReducer.Action)
        case updateDestination(SendFlowReducer.State.Destination?)
        case walletBalances(WalletBalances.Action)
    }
    
    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.memoState, action: /Action.memo) {
            MessageEditorReducer()
        }

        Scope(state: \.transactionAddressInputState, action: /Action.transactionAddressInput) {
            TransactionAddressTextFieldReducer()
        }

        Scope(state: \.transactionAmountInputState, action: /Action.transactionAmountInput) {
            TransactionAmountTextFieldReducer()
        }

        Scope(state: \.scanState, action: /Action.scan) {
            Scan()
        }

        Scope(state: \.walletBalancesState, action: /Action.walletBalances) {
            WalletBalances()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return .none

            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case let .proposal(proposal):
                state.proposal = proposal
                return .none
        
            case let .updateDestination(destination):
                state.destination = destination
                return .none

            case .reviewPressed:
                return .send(.getProposal(.send))
            
            case .getProposal(let confirmationType):
                return .run { [state, confirmationType] send in
                    do {
                        let recipient = try Recipient(state.address, network: zcashSDKEnvironment.network.networkType)
                        
                        let memo: Memo?
                        if state.transactionAddressInputState.isValidTransparentAddress {
                            memo = nil
                        } else if let memoText = state.addMemoState ? state.memoState.text : nil {
                            memo = memoText.data.isEmpty ? nil : try Memo(string: memoText.data)
                        } else {
                            memo = nil
                        }

                        let proposal = try await sdkSynchronizer.proposeTransfer(0, recipient, state.amount, memo)
                        
                        await send(.proposal(proposal))
                        await send(.confirmationRequired(confirmationType))
                    } catch {
                        if confirmationType == .requestPayment {
                            await send(.insufficientFundsForRP)
                        }
                        await send(.sendFailed(error.toZcashError()))
                    }
                }

            case .insufficientFundsForRP:
                return .none

            case .sendFailed(let error):
                state.alert = AlertState.sendFailure(error)
                return .none
                
            case .confirmationRequired:
                return .none

            case .resetForm:
                state.memoState.text = "".redacted
                return .merge(
                    .send(.transactionAmountInput(.textField(.set("".redacted)))),
                    .send(.transactionAddressInput(.textField(.set("".redacted))))
                )
                
            case .transactionAmountInput:
                return .none

            case .transactionAddressInput(.textField):
                if !state.isMemoInputEnabled {
                    state.memoState.text = "".redacted
                }
                return .none
                
            case .transactionAddressInput(.scanQR):
                return Effect.send(.updateDestination(.scanQR))

            case .transactionAddressInput:
                return .none

            case .memo:
                return .none
                
            case .scan(.foundRP(let requestPayment)):
                if case .legacy(let address) = requestPayment {
                    return .send(.scan(.found(address.value.redacted)))
                } else if case .request(let paymentRequest) = requestPayment {
                    if let payment = paymentRequest.payments.first {
                        if let memoBytes = payment.memo, let memo = try? Memo(bytes: [UInt8](memoBytes.memoData)) {
                            state.memoState.text = memo.toString()?.redacted ?? "".redacted
                        } else {
                            state.memoState.text = "".redacted
                        }
                        let numberLocale = numberFormatter.convertUSToLocale(payment.amount.toString()) ?? ""
                        var isInsufficientFunds = false
                        if let number = numberFormatter.number(numberLocale) {
                            let zatoshi = NSDecimalNumber(decimal: number.decimalValue * Decimal(Zatoshi.Constants.oneZecInZatoshi))
                            isInsufficientFunds = state.shieldedBalance.amount < zatoshi.int64Value
                        }
                        return .concatenate(
                            .send(.transactionAmountInput(.textField(.set(numberLocale.redacted)))),
                            .send(.transactionAddressInput(.textField(.set(payment.recipientAddress.value.redacted)))),
                            isInsufficientFunds
                            ? .send(.insufficientFundsForRP)
                            : .send(.getProposal(.requestPayment))
                        )
                    }
                }
                return .none
                
            case .scan(.found(let address)):
                state.transactionAddressInputState.textFieldState.text = address
                // The is valid Zcash address check is already covered in the scan feature
                // so we can be sure it's valid and thus `true` value here.
                state.transactionAddressInputState.isValidAddress = true
                state.transactionAddressInputState.isValidTransparentAddress = derivationTool.isTransparentAddress(
                    address.data,
                    zcashSDKEnvironment.network.networkType
                )
                audioServices.systemSoundVibrate()
                return Effect.send(.updateDestination(nil))

            case .scan(.cancelPressed):
                state.destination = nil
                return .none
                
            case .scan:
                return .none
                
            case .walletBalances(.balancesUpdated):
                state.shieldedBalance = state.walletBalancesState.shieldedBalance
                return .none
                
            case .walletBalances:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SendFlowReducer.Action {
    public static func sendFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Send.Alert.Failure.title)
        } message: {
            TextState(L10n.Send.Alert.Failure.message(error.detailedMessage))
        }
    }
}

// MARK: - Store

extension SendFlowStore {
    func memoStore() -> MessageEditorStore {
        self.scope(
            state: \.memoState,
            action: SendFlowReducer.Action.memo
        )
    }
    
    func scanStore() -> StoreOf<Scan> {
        self.scope(
            state: \.scanState,
            action: SendFlowReducer.Action.scan
        )
    }
}

// MARK: - ViewStore

extension SendFlowViewStore {
    var destinationBinding: Binding<SendFlowReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: SendFlowReducer.Action.updateDestination
        )
    }
    
    var bindingForScanQR: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .scanQR },
            embed: { $0 ? SendFlowReducer.State.Destination.scanQR : nil }
        )
    }
}

// MARK: Placeholders

extension SendFlowReducer.State {
    public static var initial: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial,
            walletBalancesState: .initial
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendFlowStore {
    public static var placeholder: SendFlowStore {
        SendFlowStore(
            initialState: .initial
        ) {
            SendFlowReducer()
        }
    }
}
// #endif
