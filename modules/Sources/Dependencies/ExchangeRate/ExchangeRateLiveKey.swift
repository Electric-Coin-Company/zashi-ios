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

import WalletStorage
import PartnerKeys
import Models

class ExchangeRateProvider {
    enum Constants {
        static let cmcRateURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=ZEC&convert=USD"
        static let zecKey = "ZEC"
    }
    
    var cancellable: AnyCancellable? = nil
    let eventStream = CurrentValueSubject<ExchangeRateClient.EchangeRateEvent, Never>(.value(nil))
    var latestRate: FiatCurrencyResult? = nil
    var refreshTimer: Timer? = nil
    var staleTimer: Timer? = nil
    var isStale = false
    var nilValuesCounter = 0

    init() {
        if !_XCTIsTesting {
            @Dependency(\.sdkSynchronizer) var sdkSynchronizer
            
            cancellable = sdkSynchronizer.exchangeRateUSDStream().sink { [weak self] result in
                self?.resolveResult(result)
            }
        }
    }
    
    func getCMCRate() async throws -> Double {
        guard let cmcKey = PartnerKeys.cmcKey else {
            throw "CMC API Key missing"
        }

        @Dependency(\.sdkSynchronizer) var sdkSynchronizer

        guard let url = URL(string: Constants.cmcRateURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(cmcKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")

        do {
            let (data, response) = try await sdkSynchronizer.httpRequestOverTor(request)
            
            guard (200..<300).contains(response.statusCode) else {
                throw "httpStatus \(response.statusCode)"
            }
            
            if let result = try? JSONDecoder().decode(CMCPrice.self, from: data) {
                if let zec = result.data[Constants.zecKey] {
                    return zec.quote.USD.price
                }
            }
            
            throw "decode CMCPrice.self failed"
        } catch {
            throw error
        }
    }

    func refreshExchangeRateUSD(_ rateSource: ExchangeRateClient.RateSource = .coinMarketCap) {
        if !_XCTIsTesting {
            // guard the feature is opted-in by a user
            @Dependency(\.userStoredPreferences) var userStoredPreferences

            guard let exchangeRate = userStoredPreferences.exchangeRate(), exchangeRate.automatic else {
                return
            }

            guard refreshTimer == nil else {
                return
            }

            if rateSource == .coinMarketCap {
                Task(priority: .low) {
                    do {
                        let price = try await getCMCRate()
                        
                        let fiat = FiatCurrencyResult(
                            date: Date(),
                            rate: NSDecimalNumber(value: price),
                            state: .success
                        )
                        
                        eventStream.send(.value(fiat))
                    } catch {
                        await coinMarketCapRateFailed()
                    }
                }
            } else if rateSource == .sdk {
                @Dependency(\.sdkSynchronizer) var sdkSynchronizer
                
                sdkSynchronizer.refreshExchangeRateUSD()
            }
        }
    }
    
    func coinMarketCapRateFailed() async {
        refreshExchangeRateUSD(.sdk)
    }
    
    func resolveResult(_ result: FiatCurrencyResult?) {
        // retry logic for nil value
        guard let result else {
            nilValuesCounter += 1
            
            if nilValuesCounter == 2 {
                refreshExchangeRateUSD(.coinMarketCap)
            } else if nilValuesCounter > 2 {
                eventStream.send(.stale(latestRate))
            }
            
            return
        }
        
        latestRate = result

        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

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
            @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

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
