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
import MnemonicClient
import SDKSynchronizer
import WalletStorage
import ZcashSDKEnvironment
import UIComponents

public typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
public typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

public struct SendFlowReducer: ReducerProtocol {
    private enum SyncStatusUpdatesID { case timer }
    let networkType: NetworkType

    public struct State: Equatable {
        public enum Destination: Equatable {
            case done
            case failure
            case inProgress
            case memo
            case scanQR
            case success
        }

        public var addMemoState: Bool
        public var destination: Destination?
        public var isSendingTransaction = false
        public var memoState: MultiLineTextFieldReducer.State
        public var scanState: ScanReducer.State
        public var shieldedBalance = Balance.zero
        public var transactionAddressInputState: TransactionAddressTextFieldReducer.State
        public var transactionAmountInputState: TransactionAmountTextFieldReducer.State

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

        public var isInvalidAddressFormat: Bool {
            !transactionAddressInputState.isValidAddress
            && !transactionAddressInputState.textFieldState.text.data.isEmpty
        }

        public var isInvalidAmountFormat: Bool {
            !transactionAmountInputState.textFieldState.valid
            && !transactionAmountInputState.textFieldState.text.data.isEmpty
        }
        
        public var isValidForm: Bool {
            transactionAmountInputState.amount.data > 0
            && transactionAddressInputState.isValidAddress
            && !isInsufficientFunds
            && memoState.isValid
        }
        
        public var isInsufficientFunds: Bool {
            transactionAmountInputState.amount.data > transactionAmountInputState.maxValue.data
        }
        
        public var isMemoInputEnabled: Bool {
            transactionAddressInputState.isValidAddress && !transactionAddressInputState.isValidTransparentAddress
        }
        
        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.verified.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
        
        public init(
            addMemoState: Bool,
            destination: Destination? = nil,
            isSendingTransaction: Bool = false,
            memoState: MultiLineTextFieldReducer.State,
            scanState: ScanReducer.State,
            shieldedBalance: Balance = Balance.zero,
            transactionAddressInputState: TransactionAddressTextFieldReducer.State,
            transactionAmountInputState: TransactionAmountTextFieldReducer.State
        ) {
            self.addMemoState = addMemoState
            self.destination = destination
            self.isSendingTransaction = isSendingTransaction
            self.memoState = memoState
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.transactionAddressInputState = transactionAddressInputState
            self.transactionAmountInputState = transactionAmountInputState
        }
    }

    public enum Action: Equatable {
        case memo(MultiLineTextFieldReducer.Action)
        case onAppear
        case onDisappear
        case scan(ScanReducer.Action)
        case sendPressed
        case sendTransactionSuccess
        case sendTransactionFailure(ZcashError)
        case synchronizerStateChanged(SynchronizerState)
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

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.memoState, action: /Action.memo) {
            MultiLineTextFieldReducer()
        }

        Scope(state: \.transactionAddressInputState, action: /Action.transactionAddressInput) {
            TransactionAddressTextFieldReducer(networkType: networkType)
        }

        Scope(state: \.transactionAmountInputState, action: /Action.transactionAmountInput) {
            TransactionAmountTextFieldReducer()
        }

        Scope(state: \.scanState, action: /Action.scan) {
            ScanReducer(networkType: networkType)
        }

        Reduce { state, action in
            switch action {
            case .updateDestination(.done):
                state.destination = nil
                state.memoState.text = "".redacted
                state.transactionAmountInputState.textFieldState.text = "".redacted
                state.transactionAmountInputState.amount = Int64(0).redacted
                state.transactionAddressInputState.textFieldState.text = "".redacted
                return .none

            case .updateDestination(.failure):
                state.destination = .failure
                state.isSendingTransaction = false
                return .none

            case let .updateDestination(destination):
                state.destination = destination
                return .none
                
            case .sendPressed:
                guard !state.isSendingTransaction else {
                    return .none
                }
                state.amount = Zatoshi(state.transactionAmountInputState.amount.data)
                state.address = state.transactionAddressInputState.textFieldState.text.data

                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                    let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, networkType)

                    state.isSendingTransaction = true

                    let memo: Memo?
                    if state.transactionAddressInputState.isValidTransparentAddress {
                        memo = nil
                    } else if let memoText = state.addMemoState ? state.memoState.text : nil {
                        memo = memoText.data.isEmpty ? nil : try Memo(string: memoText.data)
                    } else {
                        memo = nil
                    }

                    let recipient = try Recipient(state.address, network: networkType)
                    return .run { [state] send in
                        do {
                            await send(SendFlowReducer.Action.updateDestination(.inProgress))
                            _ = try await sdkSynchronizer.sendTransaction(spendingKey, state.amount, recipient, memo)
                            await send(SendFlowReducer.Action.sendTransactionSuccess)
                        } catch {
                            await send(SendFlowReducer.Action.sendTransactionFailure(error.toZcashError()))
                        }
                    }
                } catch {
                    return EffectTask(value: .updateDestination(.failure))
                }
                
            case .sendTransactionSuccess:
                state.isSendingTransaction = false
                return EffectTask(value: .updateDestination(.success))

            case .sendTransactionFailure:
                state.isSendingTransaction = false
                return EffectTask(value: .updateDestination(.failure))

            case .transactionAmountInput:
                return .none

            case .transactionAddressInput(.scanQR):
                return EffectTask(value: .updateDestination(.scanQR))

            case .transactionAddressInput:
                return .none

            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return sdkSynchronizer.stateStream()
                    .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                    .map(SendFlowReducer.Action.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: SyncStatusUpdatesID.timer, cancelInFlight: true)
                
            case .onDisappear:
                return .cancel(id: SyncStatusUpdatesID.timer)
                
            case .synchronizerStateChanged(let latestState):
                let shieldedBalance = latestState.shieldedBalance
                state.shieldedBalance = shieldedBalance.redacted
                state.transactionAmountInputState.maxValue = shieldedBalance.verified.amount.redacted
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
                    networkType
                )
                audioServices.systemSoundVibrate()
                return EffectTask(value: .updateDestination(nil))

            case .scan:
                return .none
            }
        }
    }
}

// MARK: - Store

extension SendFlowStore {
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

    var bindingForInProgress: Binding<Bool> {
        self.destinationBinding.map(
            extract: {
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowReducer.State.Destination.inProgress : nil }
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

    var bindingForMemo: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .memo },
            embed: { _ in SendFlowReducer.State.Destination.memo }
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
    public static var placeholder: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .placeholder,
            scanState: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .amount
        )
    }

    public static var emptyPlaceholder: Self {
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
    public static var placeholder: SendFlowStore {
        return SendFlowStore(
            initialState: .emptyPlaceholder,
            reducer: SendFlowReducer(networkType: .testnet)
        )
    }
}
// #endif
