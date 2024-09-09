//
//  WalletBalancesStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04-02-2024
//

import Foundation
import ComposableArchitecture

import ExchangeRate
import Models
import SDKSynchronizer
import Utils
import ZcashLightClientKit
import ZcashSDKEnvironment
import UserPreferencesStorage

@Reducer
public struct WalletBalances {
    private let CancelStateId = UUID()
    private let CancelRateId = UUID()

    @ObservableState
    public struct State: Equatable {
        @Shared(.inMemory(.exchangeRate)) public var currencyConversion: CurrencyConversion? = nil
        public var fiatCurrencyResult: FiatCurrencyResult?
        public var isAvailableBalanceTappable = true
        public var isExchangeRateFeatureOn = false
        public var isExchangeRateRefreshEnabled = false
        public var isExchangeRateStale = false
        public var migratingDatabase = false
        public var shieldedBalance: Zatoshi
        public var shieldedWithPendingBalance: Zatoshi
        public var totalBalance: Zatoshi
        public var transparentBalance: Zatoshi

        public var isExchangeRateUSDInFlight: Bool {
            fiatCurrencyResult?.state == .fetching
        }
        
        public var isProcessingZeroAvailableBalance: Bool {
            if shieldedBalance.amount == 0 && transparentBalance.amount > 0 {
                return false
            }
            
            return totalBalance.amount != shieldedBalance.amount && shieldedBalance.amount == 0
        }

        public var currencyValue: String {
            currencyConversion?.convert(totalBalance) ?? ""
        }
        
        public init(
            fiatCurrencyResult: FiatCurrencyResult? = nil,
            isAvailableBalanceTappable: Bool = true,
            isExchangeRateFeatureOn: Bool = false,
            isExchangeRateRefreshEnabled: Bool = false,
            isExchangeRateStale: Bool = false,
            migratingDatabase: Bool = false,
            shieldedBalance: Zatoshi = .zero,
            shieldedWithPendingBalance: Zatoshi = .zero,
            totalBalance: Zatoshi = .zero,
            transparentBalance: Zatoshi = .zero
        ) {
            self.fiatCurrencyResult = fiatCurrencyResult
            self.isAvailableBalanceTappable = isAvailableBalanceTappable
            self.isExchangeRateFeatureOn = isExchangeRateFeatureOn
            self.isExchangeRateRefreshEnabled = isExchangeRateRefreshEnabled
            self.isExchangeRateStale = isExchangeRateStale
            self.migratingDatabase = migratingDatabase
            self.shieldedBalance = shieldedBalance
            self.shieldedWithPendingBalance = shieldedWithPendingBalance
            self.totalBalance = totalBalance
            self.transparentBalance = transparentBalance
        }
    }
    
    public enum Action: Equatable {
        case availableBalanceTapped
        case balancesUpdated(AccountBalance?)
        case debugMenuStartup
        case exchangeRateRefreshTapped
        case exchangeRateEvent(ExchangeRateClient.EchangeRateEvent)
        case onAppear
        case onDisappear
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateBalances
    }

    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let exchangeRate = userStoredPreferences.exchangeRate(), exchangeRate.automatic {
                    state.isExchangeRateFeatureOn = true
                } else {
                    state.isExchangeRateFeatureOn = false
                }
                return .merge(
                    .send(.updateBalances),
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { $0.redacted }
                            .map(WalletBalances.Action.synchronizerStateChanged)
                    }
                    .cancellable(id: CancelStateId, cancelInFlight: true),
                    .publisher {
                        exchangeRate.exchangeRateEventStream()
                            .map(WalletBalances.Action.exchangeRateEvent)
                            .receive(on: mainQueue)
                    }
                    .cancellable(id: CancelRateId, cancelInFlight: true)
                )

            case .onDisappear:
                return .merge(
                    .cancel(id: CancelStateId),
                    .cancel(id: CancelRateId)
                )
                
            case .availableBalanceTapped:
                return .none

            case .exchangeRateRefreshTapped:
                if !state.isExchangeRateStale {
                    exchangeRate.refreshExchangeRateUSD()
                }
                return .none
                
            case .exchangeRateEvent(let result):
                switch result {
                case .value(let rate):
                    guard let rate else {
                        return .none
                    }
                    
                    state.fiatCurrencyResult = rate
                    state.currencyConversion = CurrencyConversion(.usd, ratio: rate.rate.doubleValue, timestamp: rate.date.timeIntervalSince1970)
                    state.isExchangeRateRefreshEnabled = false
                    state.isExchangeRateStale = false
                case .refreshEnable(let rate):
                    guard let rate else {
                        return .none
                    }
                    
                    state.fiatCurrencyResult = rate
                    state.currencyConversion = CurrencyConversion(.usd, ratio: rate.rate.doubleValue, timestamp: rate.date.timeIntervalSince1970)
                    state.isExchangeRateRefreshEnabled = true
                    state.isExchangeRateStale = false
                case .stale:
                    state.currencyConversion = nil
                    state.isExchangeRateStale = true
                    break
                }
                
                return .none

            case .updateBalances:
                return .run { send in
                    if let accountBalance = try? await sdkSynchronizer.getAccountBalance(0) {
                        await send(.balancesUpdated(accountBalance))
                    } else if let accountBalance = sdkSynchronizer.latestState().accountBalance {
                        await send(.balancesUpdated(accountBalance))
                    }
                }
                
            case .balancesUpdated(let accountBalance):
                state.shieldedBalance = (accountBalance?.saplingBalance.spendableValue ?? .zero) + (accountBalance?.orchardBalance.spendableValue ?? .zero)
                state.shieldedWithPendingBalance = (accountBalance?.saplingBalance.total() ?? .zero) + (accountBalance?.orchardBalance.total() ?? .zero)
                state.transparentBalance = accountBalance?.unshielded ?? .zero
                state.totalBalance = state.shieldedWithPendingBalance + state.transparentBalance
                return .none

            case .debugMenuStartup:
                return .none

            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)

                if snapshot.syncStatus != .unprepared {
                    state.migratingDatabase = false
                }

                return .send(.balancesUpdated(latestState.data.accountBalance?.data))
            }
        }
    }
}
