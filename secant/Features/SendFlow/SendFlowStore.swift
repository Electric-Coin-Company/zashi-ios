//
//  SendFlowStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

struct SendFlowReducer: ReducerProtocol {
    private enum SyncStatusUpdatesID {}

    struct State: Equatable {
        enum Destination: Equatable {
            case confirmation
            case inProgress
            case scanQR
            case success
            case failure
            case done
        }

        var addMemoState: Bool
        var destination: Destination?
        var isSendingTransaction = false
        var memoState: MultiLineTextFieldReducer.State
        var scanState: ScanReducer.State
        var shieldedBalance = WalletBalance.zero
        var transactionAddressInputState: TransactionAddressTextFieldReducer.State
        var transactionAmountInputState: TransactionAmountTextFieldReducer.State

        var address: String {
            get { transactionAddressInputState.textFieldState.text }
            set { transactionAddressInputState.textFieldState.text = newValue }
        }

        var amount: Zatoshi {
            get { Zatoshi(transactionAmountInputState.amount) }
            set {
                transactionAmountInputState.amount = newValue.amount
                transactionAmountInputState.textFieldState.text = newValue.amount == 0 ?
                "" :
                newValue.decimalString()
            }
        }

        var isInvalidAddressFormat: Bool {
            !transactionAddressInputState.isValidAddress
            && !transactionAddressInputState.textFieldState.text.isEmpty
        }

        var isInvalidAmountFormat: Bool {
            !transactionAmountInputState.textFieldState.valid
            && !transactionAmountInputState.textFieldState.text.isEmpty
        }
        
        var isValidForm: Bool {
            transactionAmountInputState.amount > 0
            && transactionAddressInputState.isValidAddress
            && !isInsufficientFunds
            && memoState.isValid
        }
        
        var isInsufficientFunds: Bool {
            transactionAmountInputState.amount > transactionAmountInputState.maxValue
        }

        var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.total.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
    }

    enum Action: Equatable {
        case addMemo(CheckCircleReducer.Action)
        case memo(MultiLineTextFieldReducer.Action)
        case onAppear
        case onDisappear
        case scan(ScanReducer.Action)
        case sendConfirmationPressed
        case sendTransactionResult(Result<TransactionState, NSError>)
        case synchronizerStateChanged(SDKSynchronizerState)
        case transactionAddressInput(TransactionAddressTextFieldReducer.Action)
        case transactionAmountInput(TransactionAmountTextFieldReducer.Action)
        case updateDestination(SendFlowReducer.State.Destination?)
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.addMemoState, action: /Action.addMemo) {
            CheckCircleReducer()
        }

        Scope(state: \.memoState, action: /Action.memo) {
            MultiLineTextFieldReducer()
        }

        Scope(state: \.transactionAddressInputState, action: /Action.transactionAddressInput) {
            TransactionAddressTextFieldReducer()
        }

        Scope(state: \.transactionAmountInputState, action: /Action.transactionAmountInput) {
            TransactionAmountTextFieldReducer()
        }

        Scope(state: \.scanState, action: /Action.scan) {
            ScanReducer()
        }

        Reduce { state, action in
            switch action {
            case .addMemo:
                return .none

            case .updateDestination(.done):
                state.destination = nil
                state.memoState.text = ""
                state.transactionAmountInputState.textFieldState.text = ""
                state.transactionAmountInputState.amount = 0
                state.transactionAddressInputState.textFieldState.text = ""
                return .none

            case .updateDestination(.failure):
                state.destination = .failure
                state.isSendingTransaction = false
                return .none

            case .updateDestination(.confirmation):
                state.amount = Zatoshi(state.transactionAmountInputState.amount)
                state.address = state.transactionAddressInputState.textFieldState.text
                state.destination = .confirmation
                return .none
                
            case let .updateDestination(destination):
                state.destination = destination
                return .none
                
            case .sendConfirmationPressed:
                guard !state.isSendingTransaction else {
                    return .none
                }

                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase)
                    let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0)

                    state.isSendingTransaction = true

                    let memo: Memo?
                    if let memoText = state.addMemoState ? state.memoState.text : nil {
                        memo = try Memo(string: memoText)
                    } else {
                        memo = nil
                    }

                    let recipient = try Recipient(state.address, network: zcashSDKEnvironment.network.networkType)
                    let sendTransActionEffect = sdkSynchronizer.sendTransaction(
                        with: spendingKey,
                        zatoshi: state.amount,
                        to: recipient,
                        memo: memo
                    )
                    .receive(on: mainQueue)
                    .map(SendFlowReducer.Action.sendTransactionResult)
                    .eraseToEffect()

                    return .concatenate(
                        Effect(value: .updateDestination(.inProgress)),
                        sendTransActionEffect
                    )
                } catch {
                    return Effect(value: .updateDestination(.failure))
                }
                
            case .sendTransactionResult(let result):
                state.isSendingTransaction = false
                do {
                    _ = try result.get()
                    return Effect(value: .updateDestination(.success))
                } catch {
                    return Effect(value: .updateDestination(.failure))
                }
                
            case .transactionAmountInput:
                return .none

            case .transactionAddressInput(.scanQR):
                return Effect(value: .updateDestination(.scanQR))

            case .transactionAddressInput:
                return .none

            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return sdkSynchronizer.stateChanged
                    .map(SendFlowReducer.Action.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: SyncStatusUpdatesID.self, cancelInFlight: true)
                
            case .onDisappear:
                return Effect.cancel(id: SyncStatusUpdatesID.self)
                
            case .synchronizerStateChanged(.synced):
                if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                    state.shieldedBalance = shieldedBalance
                    state.transactionAmountInputState.maxValue = shieldedBalance.total.amount
                }
                return .none
                
            case .synchronizerStateChanged:
                return .none

            case .memo:
                return .none
                
            case .scan(.found(let address)):
                state.transactionAddressInputState.textFieldState.text = address
                // The is valid Zcash address check is already covered in the scan feature
                // so we can be sure it's valid and thus `true` value here.
                state.transactionAddressInputState.isValidAddress = true
                audioServices.systemSoundVibrate()
                return Effect(value: .updateDestination(nil))

            case .scan:
                return .none
            }
        }
    }
}

// MARK: - Store

extension SendFlowStore {
    func addMemoStore() -> CheckCircleStore {
        self.scope(
            state: \.addMemoState,
            action: SendFlowReducer.Action.addMemo
        )
    }
    
    func memoStore() -> MultiLineTextFieldStore {
        self.scope(
            state: \.memoState,
            action: SendFlowReducer.Action.memo
        )
    }
    
    func scanStore() -> ScanStore {
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

    var bindingForConfirmation: Binding<Bool> {
        self.destinationBinding.map(
            extract: {
                $0 == .confirmation ||
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowReducer.State.Destination.confirmation : nil }
        )
    }

    var bindingForInProgress: Binding<Bool> {
        self.destinationBinding.map(
            extract: {
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowReducer.State.Destination.inProgress : SendFlowReducer.State.Destination.confirmation }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .success },
            embed: { _ in SendFlowReducer.State.Destination.success }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .failure },
            embed: { _ in SendFlowReducer.State.Destination.failure }
        )
    }
    
    var bindingForScanQR: Binding<Bool> {
        self.destinationBinding.map(
            extract: {
                $0 == .scanQR
            },
            embed: { $0 ? SendFlowReducer.State.Destination.scanQR : nil }
        )
    }
}

// MARK: Placeholders

extension SendFlowReducer.State {
    static var placeholder: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .amount
        )
    }

    static var emptyPlaceholder: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .placeholder
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendFlowStore {
    static var placeholder: SendFlowStore {
        return SendFlowStore(
            initialState: .emptyPlaceholder,
            reducer: SendFlowReducer()
        )
    }
}
// #endif
