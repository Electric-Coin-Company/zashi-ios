//
//  ExchangeRateLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-02-2024.
//

import Foundation
import Combine

import ComposableArchitecture
import ZcashLightClientKit

import SDKSynchronizer
import UserPreferencesStorage
import ZcashSDKEnvironment

class ExchangeRateProvider {
    var cancellable: AnyCancellable? = nil
    let eventStream = CurrentValueSubject<ExchangeRateClient.EchangeRateEvent, Never>(.value(nil))
    var latestRate: FiatCurrencyResult? = nil
    var refreshTimer: Timer? = nil
    var staleTimer: Timer? = nil
    var isStale = false
    var nilValuesCounter = 0

    init() {
        @Dependency (\.sdkSynchronizer) var sdkSynchronizer

        cancellable = sdkSynchronizer.exchangeRateUSDStream().sink { [weak self] result in
            self?.resolveResult(result)
        }
    }
    
    func refreshExchangeRateUSD() {
        // guard the feature is opted-in by a user
        @Dependency (\.userStoredPreferences) var userStoredPreferences

        guard let exchangeRate = userStoredPreferences.exchangeRate(), exchangeRate.automatic else {
            return
        }
        
        guard refreshTimer == nil else {
            return
        }
        
        @Dependency (\.sdkSynchronizer) var sdkSynchronizer

        sdkSynchronizer.refreshExchangeRateUSD()
    }
    
    func resolveResult(_ result: FiatCurrencyResult?) {
        // retry logic for nil value
        guard let result else {
            nilValuesCounter += 1
            
            if nilValuesCounter == 2 {
                refreshExchangeRateUSD()
            } else if nilValuesCounter > 2 {
                eventStream.send(.stale(latestRate))
            }
            
            return
        }
        
        latestRate = result

        @Dependency (\.zcashSDKEnvironment) var zcashSDKEnvironment

        if isStale
            && result.state != .fetching
            && Date().timeIntervalSince1970 - result.date.timeIntervalSince1970 > zcashSDKEnvironment.exchangeRateStaleLimit {
            eventStream.send(.stale(latestRate))
        } else {
            eventStream.send(.value(latestRate))
        }

        rescheduleTimer()
    }
    
    func rescheduleTimer() {
        guard let latestRate else {
            return
        }
        
        if latestRate.state == .success {
            @Dependency (\.zcashSDKEnvironment) var zcashSDKEnvironment

            isStale = false

            let diff = Date().timeIntervalSince1970 - latestRate.date.timeIntervalSince1970
            let timeToSchedule = zcashSDKEnvironment.exchangeRateIPRateLimit - diff
            
            if timeToSchedule < 0 {
                eventStream.send(.refreshEnable(latestRate))
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshTimer?.invalidate()
                    self?.refreshTimer = Timer.scheduledTimer(withTimeInterval: timeToSchedule, repeats: false) { [weak self] _ in
                        self?.refreshTimer?.invalidate()
                        self?.refreshTimer = nil
                        
                        self?.eventStream.send(.refreshEnable(self?.latestRate))
                    }

                    self?.staleTimer?.invalidate()
                    self?.staleTimer = Timer.scheduledTimer(withTimeInterval: zcashSDKEnvironment.exchangeRateStaleLimit, repeats: false) { [weak self] _ in
                        self?.staleTimer?.invalidate()
                        self?.staleTimer = nil
                        
                        self?.isStale = true
                        self?.refreshExchangeRateUSD()
                    }
                }
            }
        }
    }
}


extension ExchangeRateClient: DependencyKey {
    public static let liveValue: ExchangeRateClient = Self.live()
    
    public static func live() -> Self {
        let exchangeRateProvider = ExchangeRateProvider()
        
        return ExchangeRateClient(
            exchangeRateEventStream: { exchangeRateProvider.eventStream.eraseToAnyPublisher() },
            refreshExchangeRateUSD: {
                exchangeRateProvider.refreshExchangeRateUSD()
            }
        )
    }
}
