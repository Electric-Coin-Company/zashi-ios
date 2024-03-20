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
import PartialProposalError
import MnemonicClient
import SDKSynchronizer
import WalletStorage
import ZcashSDKEnvironment
import UIComponents
import Models
import Generated
import BalanceFormatter

public typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
public typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

public struct SendFlowReducer: Reducer {
    private let SyncStatusUpdatesID = UUID()

    public struct State: Equatable {
        public enum Destination: Equatable {
            case partialProposalError
            case sendConfirmation
            case scanQR
        }

        @PresentationState public var alert: AlertState<Action>?
        public var addMemoState: Bool
        public var destination: Destination?
        public var isSending = false
        public var memoState: MessageEditorReducer.State
        public var partialProposalErrorState: PartialProposalError.State
        public var proposal: Proposal?
        public var scanState: Scan.State
        public var spendableBalance = Zatoshi.zero
        public var totalBalance = Zatoshi.zero
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

        public var feeFormat: String {
            ZatoshiStringRepresentation.feeFormat
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

            return transactionAmountInputState.amount.data > spendableBalance.amount
        }
        
        public var isMemoInputEnabled: Bool {
            !transactionAddressInputState.isValidTransparentAddress
        }
        
        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: spendableBalance.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
        
        public var spendableBalanceString: String {
            spendableBalance.decimalString(formatter: NumberFormatter.zashiBalanceFormatter)
        }

        public var isProcessingZeroAvailableBalance: Bool {
            totalBalance.amount != spendableBalance.amount && spendableBalance.amount == 0
        }
        
        public init(
            addMemoState: Bool,
            destination: Destination? = nil,
            isSending: Bool = false,
            memoState: MessageEditorReducer.State,
            partialProposalErrorState: PartialProposalError.State,
            scanState: Scan.State,
            spendableBalance: Zatoshi = .zero,
            totalBalance: Zatoshi = .zero,
            transactionAddressInputState: TransactionAddressTextFieldReducer.State,
            transactionAmountInputState: TransactionAmountTextFieldReducer.State
        ) {
            self.addMemoState = addMemoState
            self.destination = destination
            self.isSending = isSending
            self.memoState = memoState
            self.partialProposalErrorState = partialProposalErrorState
            self.scanState = scanState
            self.spendableBalance = spendableBalance
            self.totalBalance = totalBalance
            self.transactionAddressInputState = transactionAddressInputState
            self.transactionAmountInputState = transactionAmountInputState
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case goBackPressed
        case memo(MessageEditorReducer.Action)
        case onAppear
        case onDisappear
        case partialProposalError(PartialProposalError.Action)
        case proposal(Proposal)
        case reviewPressed
        case scan(Scan.Action)
        case sendPressed
        case sendDone
        case sendFailed(ZcashError)
        case sendPartial([String], [String])
        case synchronizerStateChanged(RedactableSynchronizerState)
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

        Scope(state: \.partialProposalErrorState, action: /Action.partialProposalError) {
            PartialProposalError()
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
                return Effect.publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map{ $0.redacted }
                        .map(SendFlowReducer.Action.synchronizerStateChanged)
                }
                .cancellable(id: SyncStatusUpdatesID, cancelInFlight: true)

            case .onDisappear:
                return .cancel(id: SyncStatusUpdatesID)

            case .goBackPressed:
                state.destination = nil
                state.isSending = false
                return .none

            case .partialProposalError:
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
                        await send(.updateDestination(.sendConfirmation))
                    } catch {
                        await send(.sendFailed(error.toZcashError()))
                    }
                }

            case .sendPressed:
                state.isSending = true

                guard let proposal = state.proposal else {
                    return .send(.sendFailed("missing proposal".toZcashError()))
                }
                
                state.amount = Zatoshi(state.transactionAmountInputState.amount.data)
                state.address = state.transactionAddressInputState.textFieldState.text.data
                
                return .run { send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        switch result {
                        case .failure:
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.sendPartial(txIds, statuses))
                        case .success:
                            await send(.sendDone)
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError()))
                    }
                }

            case .sendDone:
                state.isSending = false
                state.destination = nil
                state.memoState.text = "".redacted
                state.transactionAmountInputState.textFieldState.text = "".redacted
                state.transactionAmountInputState.amount = Int64(0).redacted
                state.transactionAddressInputState.textFieldState.text = "".redacted
                return .none
                
            case .sendFailed(let error):
                state.isSending = false
                state.alert = AlertState.sendFailure(error)
                return .none
                
            case let .sendPartial(txIds, statuses):
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .send(.updateDestination(.partialProposalError))
                
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

            case .synchronizerStateChanged(let latestState):
                state.spendableBalance = latestState.data.accountBalance?.data?.saplingBalance.spendableValue ?? .zero
                state.totalBalance = latestState.data.accountBalance?.data?.saplingBalance.total() ?? .zero
                state.transactionAmountInputState.maxValue = state.spendableBalance.amount.redacted
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
            TextState(L10n.Send.Alert.Failure.message(error.message, error.code.rawValue))
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
    
    func partialProposalErrorStore() -> StoreOf<PartialProposalError> {
        self.scope(
            state: \.partialProposalErrorState,
            action: SendFlowReducer.Action.partialProposalError
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
    
    var bindingForSendConfirmation: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .sendConfirmation },
            embed: { 
                $0 ? SendFlowReducer.State.Destination.sendConfirmation :
                self.destination == .partialProposalError ? SendFlowReducer.State.Destination.partialProposalError :
                nil
            }
        )
    }
    
    var bindingForPartialProposalError: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .partialProposalError },
            embed: { $0 ? SendFlowReducer.State.Destination.partialProposalError : nil }
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
            partialProposalErrorState: .initial,
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
            SendFlowReducer()
        }
    }
}
// #endif
