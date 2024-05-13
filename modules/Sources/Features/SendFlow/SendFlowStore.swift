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

public typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
public typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

public struct SendFlowReducer: Reducer {
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
        case memo(MessageEditorReducer.Action)
        case onAppear
        case proposal(Proposal)
        case resetForm
        case reviewPressed
        case scan(Scan.Action)
        case sendConfirmationRequired
        case sendFailed(ZcashError)
        case transactionAddressInput(TransactionAddressTextFieldReducer.Action)
        case transactionAmountInput(TransactionAmountTextFieldReducer.Action)
        case updateDestination(SendFlowReducer.State.Destination?)
        case walletBalances(WalletBalances.Action)
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
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
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return .none

            case let .proposal(proposal):
                state.proposal = proposal
                return .none
        
            case let .updateDestination(destination):
                state.destination = destination
                return .none

            case .reviewPressed:
                return .run { [state] send in
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
                        await send(.sendConfirmationRequired)
                    } catch {
                        await send(.sendFailed(error.toZcashError()))
                    }
                }
                
            case .sendFailed(let error):
                state.alert = AlertState.sendFailure(error)
                return .none
                
            case .sendConfirmationRequired:
                print("__LD sendConfirmationRequired")
                return .none

            case .resetForm:
                state.memoState.text = "".redacted
                state.transactionAmountInputState.textFieldState.text = "".redacted
                state.transactionAmountInputState.amount = Int64(0).redacted
                state.transactionAddressInputState.textFieldState.text = "".redacted
                return .none
                
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
