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

//import WalletStorage
//import PartnerKeys

class ExchangeRateProvider {
    var cancellable: AnyCancellable? = nil
//    let eventStream = CurrentValueSubject<ExchangeRateClient.EchangeRateEvent, Never>(.value(nil))
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
    
//    static func getRate() async throws -> Double? {
//        @Dependency(\.sdkSynchronizer) var sdkSynchronizer
//        @Shared(.inMemory(.swapAPIAccess)) var swapAPIAccess: WalletStorage.SwapAPIAccess = .direct
//
//        guard let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=ZEC&convert=USD") else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//        if let cmcKey = PartnerKeys.cmcKey {
//            request.setValue(cmcKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
//        }
//
//        do {
//            let (data, response) = swapAPIAccess == .direct
//            ? try await URLSession.shared.data(for: request)
//            : try await sdkSynchronizer.httpRequestOverTor(request)
//            
//            guard let http = response as? HTTPURLResponse,
//                  (200..<300).contains(http.statusCode) else {
//                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
//                //throw NetworkError.httpStatus(code: code)
//                throw ""
//            }
//            
//            if let result = try? JSONDecoder().decode(PriceResponse.self, from: data) {
//                if let zec = result.data["ZEC"] {
//                    return zec.quote.USD.price
//                }
//            }
//            
//            return nil
//        } catch let urlError as URLError {
////            throw NetworkError.transport(urlError)
//            throw ""
//        } catch {
////            throw NetworkError.unknown(error)
//            throw ""
//        }
//    }
    
    
    func refreshExchangeRateUSD() {
        if !_XCTIsTesting {
            // guard the feature is opted-in by a user
            @Dependency(\.userStoredPreferences) var userStoredPreferences
            
            guard let exchangeRate = userStoredPreferences.exchangeRate(), exchangeRate.automatic else {
                return
            }
            
            guard refreshTimer == nil else {
                return
            }
            
            Task {
//                if let price = try? await ExchangeRateProvider.getRate() {
//                    
//                    var fiat = FiatCurrencyResult(
//                        date: Date(),
//                        rate: NSDecimalNumber(value: price),
//                        state: .success
//                    )
//                    
//                    eventStream.send(.value(fiat))
//                }
            }
        }

//        if !_XCTIsTesting {
//            // guard the feature is opted-in by a user
//            @Dependency(\.userStoredPreferences) var userStoredPreferences
//            
//            guard let exchangeRate = userStoredPreferences.exchangeRate(), exchangeRate.automatic else {
//                return
//            }
//            
//            guard refreshTimer == nil else {
//                return
//            }
//            
//            @Dependency(\.sdkSynchronizer) var sdkSynchronizer
//            
//            sdkSynchronizer.refreshExchangeRateUSD()
//        }
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
