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

public struct SendFlowReducer: Reducer {
    private enum SyncStatusUpdatesID { case timer }
    let networkType: NetworkType

    public struct State: Equatable {
        public enum Destination: Equatable {
            case scanQR
        }

        public var addMemoState: Bool
        public var destination: Destination?
        public var isSending = false
        public var memoState: MessageEditorReducer.State
        public var scanState: ScanReducer.State
        public var shieldedBalance = Balance.zero
        public var transactionAddressInputState: TransactionAddressTextFieldReducer.State
        public var transactionAmountInputState: TransactionAmountTextFieldReducer.State
        public var fee = Zatoshi(10_000)

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
            transactionAddressInputState.textFieldState.text.data.isEmpty ||
            !transactionAddressInputState.isValidTransparentAddress
        }
        
        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.verified.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
        
        public var spendableBalanceString: String {
            shieldedBalance.data.verified.decimalString(formatter: NumberFormatter.zashiBalanceFormatter)
        }
        
        public init(
            addMemoState: Bool,
            destination: Destination? = nil,
            memoState: MessageEditorReducer.State,
            scanState: ScanReducer.State,
            shieldedBalance: Balance = Balance.zero,
            transactionAddressInputState: TransactionAddressTextFieldReducer.State,
            transactionAmountInputState: TransactionAmountTextFieldReducer.State
        ) {
            self.addMemoState = addMemoState
            self.destination = destination
            self.memoState = memoState
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.transactionAddressInputState = transactionAddressInputState
            self.transactionAmountInputState = transactionAmountInputState
        }
    }

    public enum Action: Equatable {
        case memo(MessageEditorReducer.Action)
        case onAppear
        case onDisappear
        case scan(ScanReducer.Action)
        case sendPressed
        case sendDone
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
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.memoState, action: /Action.memo) {
            MessageEditorReducer()
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
            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return Effect.publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map(SendFlowReducer.Action.synchronizerStateChanged)
                }
                .cancellable(id: SyncStatusUpdatesID.timer, cancelInFlight: true)

            case .onDisappear:
                return .cancel(id: SyncStatusUpdatesID.timer)

            case let .updateDestination(destination):
                state.destination = destination
                return .none
                
            case .sendPressed:
                state.amount = Zatoshi(state.transactionAmountInputState.amount.data)
                state.address = state.transactionAddressInputState.textFieldState.text.data
                
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                    let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, networkType)
                    
                    let memo: Memo?
                    if state.transactionAddressInputState.isValidTransparentAddress {
                        memo = nil
                    } else if let memoText = state.addMemoState ? state.memoState.text : nil {
                        memo = memoText.data.isEmpty ? nil : try Memo(string: memoText.data)
                    } else {
                        memo = nil
                    }
                    
                    let recipient = try Recipient(state.address, network: networkType)
                    state.isSending = true
                    
                    return .run { [state] send in
                        _ = try? await sdkSynchronizer.sendTransaction(spendingKey, state.amount, recipient, memo)
                        await send(.sendDone)
                    }
                } catch {
                }
                return .none
                
            case .sendDone:
                state.destination = nil
                state.memoState.text = "".redacted
                state.transactionAmountInputState.textFieldState.text = "".redacted
                state.transactionAmountInputState.amount = Int64(0).redacted
                state.transactionAddressInputState.textFieldState.text = "".redacted
                state.isSending = false
                return .none
                
            case .transactionAmountInput:
                return .none

            case .transactionAddressInput(.scanQR):
                return Effect.send(.updateDestination(.scanQR))

            case .transactionAddressInput:
                return .none
                
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
                return Effect.send(.updateDestination(nil))

            case .scan:
                return .none
            }
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
    public static var initial: Self {
        .init(
            addMemoState: true,
            destination: nil,
            memoState: .initial,
            scanState: .initial,
            transactionAddressInputState: .initial,
            transactionAmountInputState: .initial
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendFlowStore {
    public static var placeholder: SendFlowStore {
        SendFlowStore(
            initialState: .initial
        ) {
            SendFlowReducer(networkType: .testnet)
        }
    }
}
// #endif
