//
//  Near1Click.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-23.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import SDKSynchronizer
import WalletStorage

struct Near1Click {
    let submitDepositTxId: (String, String) async throws -> Void
    let swapAssets: () async throws -> IdentifiedArrayOf<SwapAsset>
    let quote: (Bool, Bool, Int, SwapAsset, SwapAsset, String, String, String) async throws -> SwapQuote
    let status: (String) async throws -> SwapDetails
}

extension Near1Click {
    public static let liveValue: Near1Click = Self.live()
    
    public static func live() -> Self {
        @Dependency(\.sdkSynchronizer) var sdkSynchronizer
        @Shared(.inMemory(.swapAPIAccess)) var swapAPIAccess: WalletStorage.SwapAPIAccess? = nil

        return Near1Click(
            //    public static let liveValue = Self(
            submitDepositTxId: { txId, depositAddress in
                guard swapAPIAccess != .notResolved else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: networking hasn't been resolved yet")
                }

                guard let url = URL(string: "https://1click.chaindefuser.com/v0/deposit/submit") else {
                    throw URLError(.badURL)
                }
                
                let requestData = SwapSubmitHash(
                    txHash: txId,
                    depositAddress: depositAddress
                )
                
                guard let jsonData = try? JSONEncoder().encode(requestData) else {
                    fatalError("Failed to encode JSON")
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let (data, response) = swapAPIAccess == .direct
                ? try await URLSession.shared.data(for: request)
                : try await sdkSynchronizer.httpRequestOverTor(request)

                guard let _ = response as? HTTPURLResponse else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: Invalid response")
                }
                
                guard let _ = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: Cannot parse response")
                }
            },
            swapAssets: {
                guard swapAPIAccess != .notResolved else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: networking hasn't been resolved yet")
                }

                guard let url = URL(string: "https://1click.chaindefuser.com/v0/tokens") else {
                    throw URLError(.badURL)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let (data, _) = swapAPIAccess == .direct
                ? try await URLSession.shared.data(for: request)
                : try await sdkSynchronizer.httpRequestOverTor(request)

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
                    
                    guard let decimals = dict["decimals"] as? Int else {
                        return nil
                    }
                    
                    return SwapAsset(
                        chain: chain,
                        token: symbol,
                        assetId: assetId,
                        usdPrice: Decimal(usdPrice),
                        decimals: decimals
                    )
                }
                
                return IdentifiedArrayOf(uniqueElements: chainAssets)
            },
            quote: { dry, exactInput, slippageTolerance, zecAsset, toAsset, refundTo, destination, amount in
                guard swapAPIAccess != .notResolved else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: networking hasn't been resolved yet")
                }

                guard let url = URL(string: "https://1click.chaindefuser.com/v0/quote") else {
                    throw URLError(.badURL)
                }
                
                // Deadline in ISO 8601 UTC format
                let now = Date()
                let tenMinutesLater = now.addingTimeInterval(10 * 60)
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
                isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                let deadline = isoFormatter.string(from: tenMinutesLater)
                
                let requestData = SwapQuoteRequest(
                    dry: dry,
                    swapType: exactInput ? "EXACT_INPUT" : "EXACT_OUTPUT",
                    slippageTolerance: slippageTolerance,
                    originAsset: zecAsset.assetId,
                    depositType: "ORIGIN_CHAIN",
                    destinationAsset: toAsset.assetId,
                    amount: amount,
                    refundTo: refundTo,
                    refundType: "ORIGIN_CHAIN",
                    recipient: destination,
                    recipientType: "DESTINATION_CHAIN",
                    deadline: deadline,
                    quoteWaitingTimeMs: 3000
                )
                
                guard let jsonData = try? JSONEncoder().encode(requestData) else {
                    fatalError("Failed to encode JSON")
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                let (data, response) = swapAPIAccess == .direct
                ? try await URLSession.shared.data(for: request)
                : try await sdkSynchronizer.httpRequestOverTor(request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw SwapAndPayClient.EndpointError.message("Quote: Invalid response")
                }
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw SwapAndPayClient.EndpointError.message("Quote: Cannot parse response")
                }
                
                if httpResponse.statusCode >= 400 {
                    // evaluate error
                    if let errorMsg = jsonObject["message"] as? String {
                        var errorMsgConverted = errorMsg
                        
                        // insufficient amount transformations
                        if errorMsg.contains("Amount is too low for bridge, try at least") {
                            if let value = errorMsg.split(separator: "Amount is too low for bridge, try at least ").last {
                                let valueDecimal = NSDecimalNumber(string: String(value)).decimalValue
                                
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.minimumFractionDigits = 2
                                formatter.maximumFractionDigits = 8
                                formatter.usesGroupingSeparator = false
                                formatter.locale = Locale.current
                                
                                // ZEC asset
                                if exactInput {
                                    let zecAmount = (NSDecimalNumber(decimal: valueDecimal / Decimal(Zatoshi.Constants.oneZecInZatoshi))).decimalValue.simplified
                                    
                                    let localeValue = formatter.string(from: NSDecimalNumber(decimal: zecAmount)) ?? "\(zecAmount)"
                                    errorMsgConverted = "Amount is too low for bridge, try at least \(localeValue) ZEC."
                                } else {
                                    // selected Asset
                                    let tokenAmount = (valueDecimal / Decimal(pow(10.0, Double(toAsset.decimals)))).simplified
                                    
                                    let localeValue = formatter.string(from: NSDecimalNumber(decimal: tokenAmount)) ?? "\(tokenAmount)"
                                    errorMsgConverted = "Amount is too low for bridge, try at least \(localeValue) \(toAsset.token)."
                                }
                            }
                        }
                        
                        throw SwapAndPayClient.EndpointError.message(errorMsgConverted)
                    } else {
                        throw SwapAndPayClient.EndpointError.message("Unknown error")
                    }
                }
                
                guard let quote = jsonObject["quote"] as? [String: Any],
                      let depositAddress = quote["depositAddress"] as? String,
                      let amountInString = quote["amountIn"] as? String,
                      let amountInUsdString = quote["amountInUsd"] as? String,
                      let minAmountInString = quote["minAmountIn"] as? String,
                      let amountOutString = quote["amountOut"] as? String,
                      let amountOutUsdString = quote["amountOutUsd"] as? String,
                      let timeEstimate = quote["timeEstimate"] as? Int else {
                    throw SwapAndPayClient.EndpointError.message("Parse of the quote failed.")
                }
                
                let amountIn = NSDecimalNumber(string: amountInString).decimalValue
                let minAmountIn = NSDecimalNumber(string: minAmountInString).decimalValue
                let amountOut = NSDecimalNumber(string: amountOutString).decimalValue
                
                return SwapQuote(
                    depositAddress: depositAddress,
                    amountIn: amountIn,
                    amountInUsd: amountInUsdString,
                    minAmountIn: minAmountIn,
                    amountOut: amountOut / Decimal(pow(10.0, Double(toAsset.decimals))),
                    amountOutUsd: amountOutUsdString,
                    timeEstimate: TimeInterval(timeEstimate)
                )
            },
            status: { depositAddress in
                guard swapAPIAccess != .notResolved else {
                    throw SwapAndPayClient.EndpointError.message("Submit deposit id: networking hasn't been resolved yet")
                }

                guard let url = URL(string: "https://1click.chaindefuser.com/v0/status?depositAddress=\(depositAddress)") else {
                    throw URLError(.badURL)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let (data, response) = swapAPIAccess == .direct
                ? try await URLSession.shared.data(for: request)
                : try await sdkSynchronizer.httpRequestOverTor(request)

                guard let _ = response as? HTTPURLResponse else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Invalid response")
                }
                
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Cannot parse response")
                }
                
                guard let statusStr = jsonObject["status"] as? String else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Missing `status` parameter.")
                }
                let status: SwapDetails.Status = switch statusStr {
                case "PENDING_DEPOSIT": .pending
                case "REFUNDED": .refunded
                case "SUCCESS": .success
                default: .pending
                }
                
                guard let quoteResponseDict = jsonObject["quoteResponse"] as? [String: Any],
                      let quoteRequestDict = quoteResponseDict["quoteRequest"] as? [String: Any] else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Missing `quoteRequest` parameter.")
                }
                
                guard let swapType = quoteRequestDict["swapType"] as? String else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Missing `swapType` parameter.")
                }
                
                guard let destinationAsset = quoteRequestDict["destinationAsset"] as? String else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Missing `destinationAsset` parameter.")
                }
                
                guard let swapDetailsDict = jsonObject["swapDetails"] as? [String: Any] else {
                    throw SwapAndPayClient.EndpointError.message("Check status: Missing `swapDetails` parameter.")
                }
                
                var slippage: Decimal?
                if let slippageInt = swapDetailsDict["slippage"] as? Int {
                    slippage = Decimal(slippageInt) * 0.01
                }
                
                var amountInFormattedDecimal: Decimal?
                if let amountInFormatted = swapDetailsDict["amountInFormatted"] as? String {
                    amountInFormattedDecimal = amountInFormatted.usDecimal
                }
                
                var amountOutFormattedDecimal: Decimal?
                if let amountOutFormatted = swapDetailsDict["amountOutFormatted"] as? String {
                    amountOutFormattedDecimal = amountOutFormatted.usDecimal
                }
                
                return SwapDetails(
                    amountInFormatted: amountInFormattedDecimal,
                    amountInUsd: swapDetailsDict["amountInUsd"] as? String,
                    amountOutFormatted: amountOutFormattedDecimal,
                    amountOutUsd: swapDetailsDict["amountOutUsd"] as? String,
                    destinationAsset: destinationAsset,
                    isSwap: swapType == "EXACT_INPUT",
                    slippage: slippage,
                    status: status
                )
            }
        )
    }
}

/*
 
 
 {
   "status": "REFUNDED",
   "updatedAt": "2025-06-20T10:57:41.000Z",
   "swapDetails": {
     "intentHashes": [
       "2vkMVKd5BKmChUwZSL772uvBB2dqjYMHem1SDxbk8qqS"
     ],
     "nearTxHashes": [
       "6BkmfLGnNzS3NkQi5LQoSWUSJw7ZdVkWcBJCVXH9XBo4",
       "Dn3kRwf33rawayWwQ3ZCwo8r6Zrm83tp7e6KqwhoB3ms"
     ],
     "amountIn": null,
     "amountInFormatted": null,
     "amountInUsd": null,
     "amountOut": null,
     "amountOutFormatted": null,
     "amountOutUsd": null,
     "slippage": null,
     "refundedAmount": "53000",
     "refundedAmountFormatted": "0.00053",
     "refundedAmountUsd": "0.0222",
     "originChainTxHashes": [
       {
         "hash": "0839045295a9ea2967e673773626ef9ff3ee97ffa2ce4411f2d988930dfc297b",
         "explorerUrl": ""
       }
     ],
     "destinationChainTxHashes": []
   },
   "quoteResponse": {
     "timestamp": "2025-06-20T10:45:25.435Z",
     "signature": "ed25519:2bVVxD95TSyQrNQK2fKhjaknafHab9GEmyH7u83fGSFNHzb3aFwHLjPrg6HEgRa1rfrMsBzpD1NkEmMePEBYLnUf",
     "quoteRequest": {
       "dry": false,
       "swapType": "EXACT_INPUT",
       "slippageTolerance": 1,
       "originAsset": "nep141:zec.omft.near",
       "depositType": "ORIGIN_CHAIN",
       "destinationAsset": "nep141:17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1",
       "amount": "100000",
       "refundTo": "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
       "refundType": "ORIGIN_CHAIN",
       "recipient": "0526d09ea436f7460791f255789884ad86ae2397ca6c4dc24d0b748e26df1633",
       "recipientType": "DESTINATION_CHAIN",
       "deadline": "2025-06-20T10:55:25.000Z",
       "appFees": []
     },
     "quote": {
       "amountIn": "100000",
       "amountInFormatted": "0.001",
       "amountInUsd": "0.0419",
       "minAmountIn": "100000",
       "amountOut": "41977",
       "amountOutFormatted": "0.041977",
       "amountOutUsd": "0.0420",
       "minAmountOut": "41973",
       "timeWhenInactive": "2025-06-21T10:45:28.809Z",
       "depositAddress": "t1ZVjVfpcCm7mqNqYQ3VAs8NreDWQt2AB22",
       "deadline": "2025-06-21T10:45:28.809Z",
       "timeEstimate": 105
     }
   }
 }
 
 {
   "status": "PENDING_DEPOSIT",
   "updatedAt": "2025-06-22T10:31:58.821Z",
   "swapDetails": {
     "intentHashes": [],
     "nearTxHashes": [],
     "amountIn": null,
     "amountInFormatted": null,
     "amountInUsd": null,
     "amountOut": null,
     "amountOutFormatted": null,
     "amountOutUsd": null,
     "slippage": null,
     "refundedAmount": "0",
     "refundedAmountFormatted": "0",
     "refundedAmountUsd": "0",
     "originChainTxHashes": [],
     "destinationChainTxHashes": []
   },
   "quoteResponse": {
     "timestamp": "2025-06-22T10:31:52.430Z",
     "signature": "ed25519:3ueLEvcRsGfwdihGc8BVCywJCVcGDrwi3WbZNPq7ktLUtC4n7VLjZAUtcNyveFcgNri3g8HS2KBRCUzcerYATpaq",
     "quoteRequest": {
       "dry": false,
       "swapType": "EXACT_INPUT",
       "slippageTolerance": 100,
       "originAsset": "nep141:zec.omft.near",
       "depositType": "ORIGIN_CHAIN",
       "destinationAsset": "nep141:aaaaaa20d9e0e2461697782ef11675f668207961.factory.bridge.near",
       "amount": "100000",
       "refundTo": "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
       "refundType": "ORIGIN_CHAIN",
       "recipient": "0526d09ea436f7460791f255789884ad86ae2397ca6c4dc24d0b748e26df1633",
       "recipientType": "DESTINATION_CHAIN",
       "deadline": "2025-06-22T10:41:52.000Z",
       "appFees": []
     },
     "quote": {
       "amountIn": "100000",
       "amountInFormatted": "0.001",
       "amountInUsd": "0.0385",
       "minAmountIn": "100000",
       "amountOut": "523180024550103497",
       "amountOutFormatted": "0.523180024550103497",
       "amountOutUsd": "0.0362",
       "minAmountOut": "517948224304602462",
       "timeWhenInactive": "2025-06-23T10:31:58.816Z",
       "depositAddress": "t1evCZ4Zc3h1fueaZTbgwZkXcssajcWUKCV",
       "deadline": "2025-06-23T10:31:58.816Z",
       "timeEstimate": 105
     }
   }
 }
 
 */



/*
 
 {
   "status": "SUCCESS",
   "updatedAt": "2025-06-20T08:04:23.000Z",
   "swapDetails": {
     "intentHashes": [
       "3T2ZsfkmCyms3r18r6MgxZjZbmcuKuN8KrX2DBrxVjm2"
     ],
     "nearTxHashes": [
       "G8eJHbMt3bS3Mey1oZs8VZHcm5EARyTWuKAQ12VwKofq",
       "9oS2NbV1aRyRwQ5CZWN4JpyqiipoWLu1QpL7Vo2kRp2C"
     ],
     "amountIn": "2388503",
     "amountInFormatted": "0.02388503",
     "amountInUsd": "0.9993",
     "amountOut": "1000000",
     "amountOutFormatted": "1.0",
     "amountOutUsd": "0.9999",
     "slippage": 0,
     "refundedAmount": "0",
     "refundedAmountFormatted": "0",
     "refundedAmountUsd": "0",
     "originChainTxHashes": [],
     "destinationChainTxHashes": [
       {
         "hash": "9oS2NbV1aRyRwQ5CZWN4JpyqiipoWLu1QpL7Vo2kRp2C",
         "explorerUrl": ""
       }
     ]
   },
   "quoteResponse": {
     "timestamp": "2025-06-20T08:00:55.511Z",
     "signature": "ed25519:K6syLxwbFx68SYb9dTYRor5YXyagpU7Hn9MKm6XEx3RRz2G2GcVtdZkrYNiVjQmz3dLxGGy3Czx1UP9jUpz1Kpk",
     "quoteRequest": {
       "dry": false,
       "swapType": "EXACT_OUTPUT",
       "slippageTolerance": 200,
       "originAsset": "nep141:zec.omft.near",
       "depositType": "ORIGIN_CHAIN",
       "destinationAsset": "nep141:17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1",
       "amount": "1000000",
       "refundTo": "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
       "refundType": "ORIGIN_CHAIN",
       "recipient": "0526d09ea436f7460791f255789884ad86ae2397ca6c4dc24d0b748e26df1633",
       "recipientType": "DESTINATION_CHAIN",
       "deadline": "2025-06-20T08:10:55.000Z",
       "appFees": []
     },
     "quote": {
       "amountIn": "2438412",
       "amountInFormatted": "0.02438412",
       "amountInUsd": "1.0216",
       "minAmountIn": "2389644",
       "amountOut": "1000000",
       "amountOutFormatted": "1.0",
       "amountOutUsd": "0.9999",
       "minAmountOut": "1000000",
       "timeWhenInactive": "2025-06-21T08:00:59.109Z",
       "depositAddress": "t1SLqm2JGH8ectbEpvN1x1GPVDjwJpNLepo",
       "deadline": "2025-06-21T08:00:59.109Z",
       "timeEstimate": 105
     }
   }
 }
 
 {
   "status": "REFUNDED",
   "updatedAt": "2025-06-20T10:57:41.000Z",
   "swapDetails": {
     "intentHashes": [
       "2vkMVKd5BKmChUwZSL772uvBB2dqjYMHem1SDxbk8qqS"
     ],
     "nearTxHashes": [
       "6BkmfLGnNzS3NkQi5LQoSWUSJw7ZdVkWcBJCVXH9XBo4",
       "Dn3kRwf33rawayWwQ3ZCwo8r6Zrm83tp7e6KqwhoB3ms"
     ],
     "amountIn": null,
     "amountInFormatted": null,
     "amountInUsd": null,
     "amountOut": null,
     "amountOutFormatted": null,
     "amountOutUsd": null,
     "slippage": null,
     "refundedAmount": "53000",
     "refundedAmountFormatted": "0.00053",
     "refundedAmountUsd": "0.0222",
     "originChainTxHashes": [
       {
         "hash": "0839045295a9ea2967e673773626ef9ff3ee97ffa2ce4411f2d988930dfc297b",
         "explorerUrl": ""
       }
     ],
     "destinationChainTxHashes": []
   },
   "quoteResponse": {
     "timestamp": "2025-06-20T10:45:25.435Z",
     "signature": "ed25519:2bVVxD95TSyQrNQK2fKhjaknafHab9GEmyH7u83fGSFNHzb3aFwHLjPrg6HEgRa1rfrMsBzpD1NkEmMePEBYLnUf",
     "quoteRequest": {
       "dry": false,
       "swapType": "EXACT_INPUT",
       "slippageTolerance": 1,
       "originAsset": "nep141:zec.omft.near",
       "depositType": "ORIGIN_CHAIN",
       "destinationAsset": "nep141:17208628f84f5d6ad33f0da3bbbeb27ffcb398eac501a31bd6ad2011e36133a1",
       "amount": "100000",
       "refundTo": "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
       "refundType": "ORIGIN_CHAIN",
       "recipient": "0526d09ea436f7460791f255789884ad86ae2397ca6c4dc24d0b748e26df1633",
       "recipientType": "DESTINATION_CHAIN",
       "deadline": "2025-06-20T10:55:25.000Z",
       "appFees": []
     },
     "quote": {
       "amountIn": "100000",
       "amountInFormatted": "0.001",
       "amountInUsd": "0.0419",
       "minAmountIn": "100000",
       "amountOut": "41977",
       "amountOutFormatted": "0.041977",
       "amountOutUsd": "0.0420",
       "minAmountOut": "41973",
       "timeWhenInactive": "2025-06-21T10:45:28.809Z",
       "depositAddress": "t1ZVjVfpcCm7mqNqYQ3VAs8NreDWQt2AB22",
       "deadline": "2025-06-21T10:45:28.809Z",
       "timeEstimate": 105
     }
   }
 }
 
 {
   "status": "PENDING_DEPOSIT",
   "updatedAt": "2025-06-22T10:31:58.821Z",
   "swapDetails": {
     "intentHashes": [],
     "nearTxHashes": [],
     "amountIn": null,
     "amountInFormatted": null,
     "amountInUsd": null,
     "amountOut": null,
     "amountOutFormatted": null,
     "amountOutUsd": null,
     "slippage": null,
     "refundedAmount": "0",
     "refundedAmountFormatted": "0",
     "refundedAmountUsd": "0",
     "originChainTxHashes": [],
     "destinationChainTxHashes": []
   },
   "quoteResponse": {
     "timestamp": "2025-06-22T10:31:52.430Z",
     "signature": "ed25519:3ueLEvcRsGfwdihGc8BVCywJCVcGDrwi3WbZNPq7ktLUtC4n7VLjZAUtcNyveFcgNri3g8HS2KBRCUzcerYATpaq",
     "quoteRequest": {
       "dry": false,
       "swapType": "EXACT_INPUT",
       "slippageTolerance": 100,
       "originAsset": "nep141:zec.omft.near",
       "depositType": "ORIGIN_CHAIN",
       "destinationAsset": "nep141:aaaaaa20d9e0e2461697782ef11675f668207961.factory.bridge.near",
       "amount": "100000",
       "refundTo": "t1LPZcKWXfAQeB4pNCUbRFzHi96R1KNpdo8",
       "refundType": "ORIGIN_CHAIN",
       "recipient": "0526d09ea436f7460791f255789884ad86ae2397ca6c4dc24d0b748e26df1633",
       "recipientType": "DESTINATION_CHAIN",
       "deadline": "2025-06-22T10:41:52.000Z",
       "appFees": []
     },
     "quote": {
       "amountIn": "100000",
       "amountInFormatted": "0.001",
       "amountInUsd": "0.0385",
       "minAmountIn": "100000",
       "amountOut": "523180024550103497",
       "amountOutFormatted": "0.523180024550103497",
       "amountOutUsd": "0.0362",
       "minAmountOut": "517948224304602462",
       "timeWhenInactive": "2025-06-23T10:31:58.816Z",
       "depositAddress": "t1evCZ4Zc3h1fueaZTbgwZkXcssajcWUKCV",
       "deadline": "2025-06-23T10:31:58.816Z",
       "timeEstimate": 105
     }
   }
 }
 
 */
