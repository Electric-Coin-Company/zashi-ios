//
//  Near1Click.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-23.
//

import Foundation
import ComposableArchitecture

struct Near1Click {
    let swapAssets: () async throws -> IdentifiedArrayOf<SwapAsset>
    let quote: () async throws -> Void
}

extension Near1Click {
    public static let liveValue = Self(
        swapAssets: {
            guard let url = URL(string: "https://1click.chaindefuser.com/v0/tokens") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw URLError(.cannotParseResponse)
            }

            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.numberStyle = .decimal
            
            let chainAssets = jsonObject.compactMap { dict -> SwapAsset? in
                guard let chain = dict["blockchain"] as? String else {
                    return nil
                }

                guard let symbol = dict["symbol"] as? String else {
                    return nil
                }

                guard let assetId = dict["assetId"] as? String else {
                    return nil
                }

                guard let usdPrice = dict["price"] as? Double else {
                    return nil
                }

                return SwapAsset(
                    chain: chain,
                    token: symbol,
                    assetId: assetId,
                    usdPrice: usdPrice
                )
            }
            
            return IdentifiedArrayOf(uniqueElements: chainAssets)
        },
        quote: {
            guard let url = URL(string: "https://1click.chaindefuser.com/v0/quote") else {
                throw URLError(.badURL)
            }

            let requestData = SwapQuote(
                dry: true,
                swapType: "EXACT_OUTPUT",
                slippageTolerance: 100,
                originAsset: "nep141:zec.omft.near",
                depositType: "ORIGIN_CHAIN",
                destinationAsset: "nep141:eth.omft.near",
                amount: "1000",
                refundTo: "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
                refundType: "ORIGIN_CHAIN",
                recipient: "0xF8D1E1997E253315D765E501E212B67C6428D317",
                recipientType: "DESTINATION_CHAIN",
                deadline: "2025-08-24T14:15:22Z",
                referral: "referral",
                quoteWaitingTimeMs: 3000,
                appFees: [
                    AppFee(recipient: "recipient.near", fee: 100)
                ]
            )
            
//            0xF8D1E1997E253315D765E501E212B67C6428D317
//            13QkxhNMrTPxoCkRdYdJ65tFuwXPhL5gLS2Z5Nr6gjRK
            
//            t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8
//            0x2527D02599Ba641c19FEa793cD0F167589a0f10D
            
            guard let jsonData = try? JSONEncoder().encode(requestData) else {
                fatalError("Failed to encode JSON")
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return
            }
            
            print("📡 Status code: \(httpResponse.statusCode)")
            
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("✅ Response: \(responseString)")
//            }
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw URLError(.cannotParseResponse)
            }
            
            print("✅ Response: \(jsonObject)")
        }
    )
}
