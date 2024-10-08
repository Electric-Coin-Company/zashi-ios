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
import NumberFormatter
import UserPreferencesStorage

@Reducer
public struct SendFlow {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case partialProposalError
            case scanQR
        }

        @Presents public var alert: AlertState<Action>?
        public var addMemoState: Bool
        @Shared(.inMemory(.exchangeRate)) public var currencyConversion: CurrencyConversion? = nil
        public var destination: Destination?
        public var isCurrencyConversionEnabled = false
        public var memoState: MessageEditor.State
        public var proposal: Proposal?
        public var scanState: Scan.State
        public var shieldedBalance: Zatoshi
        public var walletBalancesState: WalletBalances.State
        
        public var isValidAddress = false
        public var isValidTransparentAddress = false
        public var isValidTexAddress = false

        public var address: RedactableString = .empty
        public var zecAmountText: RedactableString = .empty
        public var currencyText: RedactableString = .empty

        public var amount: Zatoshi {
            get {
                if !_XCTIsTesting {
                    @Dependency(\.numberFormatter) var numberFormatter
                    var amount = Zatoshi.zero
                    
                    guard let number = numberFormatter.number(zecAmountText.data) else {
                        return amount
                    }
                    amount = Zatoshi(NSDecimalNumber(
                        decimal: number.decimalValue * Decimal(Zatoshi.Constants.oneZecInZatoshi)
                    ).roundedZec.int64Value)
                    
                    return amount
                } else {
                    return .zero
                }
            }
            set {
                zecAmountText = newValue.amount == 0 
                ? .empty
                : newValue.decimalString().redacted
            }
        }

        public var currencySymbol: String {
            currencyConversion?.iso4217.symbol ?? ""
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

        public var isValidAmount: Bool {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter
                
                return numberFormatter.number(zecAmountText.data) != nil
            } else {
                return true
            }
        }
        
        public var isInvalidAddressFormat: Bool {
            !address.data.isEmpty
            && !isValidAddress
        }

        public var isInvalidAmountFormat: Bool {
            if !_XCTIsTesting {
                @Dependency(\.numberFormatter) var numberFormatter
                
                return !zecAmountText.data.isEmpty
                && !isValidAmount
                || (numberFormatter.number(currencyText.data) == nil && !currencyText.data.isEmpty)
            } else {
                return true
            }
        }
        
        public var isValidForm: Bool {
            isValidAddress
            && !isInsufficientFunds
            && memoState.isValid
            && isValidAmount
        }

        public var isInsufficientFunds: Bool {
            guard isValidAmount else { return false }

            return amount.amount > shieldedBalance.amount
        }
        
        public var isMemoInputEnabled: Bool {
            !isValidTransparentAddress && !isValidTexAddress
        }
                
        public var spendableBalanceString: String {
            shieldedBalance.decimalString(formatter: NumberFormatter.zashiBalanceFormatter)
        }
        
        public init(
            addMemoState: Bool,
            destination: Destination? = nil,
            memoState: MessageEditor.State,
            scanState: Scan.State,
            shieldedBalance: Zatoshi = .zero,
            walletBalancesState: WalletBalances.State
        ) {
            self.addMemoState = addMemoState
            self.destination = destination
            self.memoState = memoState
            self.scanState = scanState
            self.shieldedBalance = shieldedBalance
            self.walletBalancesState = walletBalancesState
        }
    }

    public enum Action: Equatable {
        case addressUpdated(RedactableString)
        case alert(PresentationAction<Action>)
        case currencyUpdated(RedactableString)
        case exchangeRateSetupChanged
        case memo(MessageEditor.Action)
        case onAppear
        case proposal(Proposal)
        case resetForm
        case reviewPressed
        case scan(Scan.Action)
        case sendConfirmationRequired
        case sendFailed(ZcashError)
        case syncAmounts(Bool)
        case updateDestination(SendFlow.State.Destination?)
        case walletBalances(WalletBalances.Action)
        case zecAmountUpdated(RedactableString)
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.memoState, action: \.memo) {
            MessageEditor()
        }

        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }

        Scope(state: \.walletBalancesState, action: \.walletBalances) {
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
                return .send(.exchangeRateSetupChanged)
                
            case .exchangeRateSetupChanged:
                if let automatic = userStoredPreferences.exchangeRate()?.automatic, automatic {
                    state.isCurrencyConversionEnabled = true
                } else {
                    state.isCurrencyConversionEnabled = false
                }
                return .none

            case let .proposal(proposal):
                state.proposal = proposal
                return .none
        
            case let .updateDestination(destination):
                state.destination = destination
                return .none

            case .walletBalances(.exchangeRateEvent(let result)):
                switch result {
                case .value(let rate), .refreshEnable(let rate):
                    if let rate {
                        state.currencyConversion = CurrencyConversion(.usd, ratio: rate.rate.doubleValue, timestamp: rate.date.timeIntervalSince1970)
                        return .send(.syncAmounts(false))
                    }
                case .stale:
                    state.currencyConversion = nil
                    return .none
                }
                return .none
                
            case .reviewPressed:
                return .run { [state] send in
                    do {
                        let recipient = try Recipient(state.address.data, network: zcashSDKEnvironment.network.networkType)
                        
                        let memo: Memo?
                        if state.isValidTransparentAddress || state.isValidTexAddress {
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
                return .none

            case .resetForm:
                state.memoState.text = .empty
                state.address = .empty
                state.zecAmountText = .empty
                state.currencyText = .empty
                state.isValidAddress = false
                state.isValidTransparentAddress = false
                state.isValidTexAddress = false
                return .none
                
            case .syncAmounts(let zecToCurrency):
                guard let currencyConversion = state.currencyConversion else {
                    return .none
                }
                if zecToCurrency {
                    if state.zecAmountText.data.isEmpty || !state.isValidAmount {
                        state.currencyText = .empty
                    } else {
                        let value: Double = currencyConversion.convert(Zatoshi(state.amount.amount))
                        state.currencyText = Decimal(value).formatted(.number.precision(.fractionLength(2))).redacted
                    }
                } else {
                    if let number = numberFormatter.number(state.currencyText.data) {
                        if let value = Double(exactly: number) {
                            let value2 = currencyConversion.convert(value)
                            state.zecAmountText = value2.decimalString().redacted
                        }
                    } else if state.currencyText.data.isEmpty {
                        state.zecAmountText = .empty
                    }
                }
                return .none

            case .memo:
                return .none
                
            case .scan(.found(let address)):
                state.address = address
                // The is valid Zcash address check is already covered in the scan feature
                // so we can be sure it's valid and thus `true` value here.
                state.isValidAddress = true
                state.isValidTransparentAddress = derivationTool.isTransparentAddress(
                    address.data,
                    zcashSDKEnvironment.network.networkType
                )
                state.isValidTexAddress = derivationTool.isTexAddress(
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
                
            case .addressUpdated(let newValue):
                let network = zcashSDKEnvironment.network.networkType
                state.address = newValue
                state.isValidAddress = derivationTool.isZcashAddress(state.address.data, network)
                state.isValidTransparentAddress = derivationTool.isTransparentAddress(state.address.data, network)
                state.isValidTexAddress = derivationTool.isTexAddress(state.address.data, network)
                if !state.isMemoInputEnabled {
                    state.memoState.text = .empty
                }
                return .none
                
            case .currencyUpdated(let newValue):
                state.currencyText = newValue
                return .send(.syncAmounts(false))
                
            case .zecAmountUpdated(let newValue):
                state.zecAmountText = newValue
                return .send(.syncAmounts(true))
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SendFlow.Action {
    public static func sendFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Send.Alert.Failure.title)
        } message: {
            TextState(L10n.Send.Alert.Failure.message(error.detailedMessage))
        }
    }
}
