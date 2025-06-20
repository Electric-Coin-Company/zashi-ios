//
//  Near1Click.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-23.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

struct Near1Click {
    let submitDepositTxId: (String, String) async throws -> Void
    let swapAssets: () async throws -> IdentifiedArrayOf<SwapAsset>
    let quote: (Bool, Bool, Int, SwapAsset, SwapAsset, String, String, String) async throws -> SwapQuote
}

extension Near1Click {
    public static let liveValue = Self(
        submitDepositTxId: { txId, depositAddress in
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
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SwapAndPayClient.EndpointError.message("Invalid response")
            }
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw SwapAndPayClient.EndpointError.message("Cannot parse response")
            }
        },
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
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SwapAndPayClient.EndpointError.message("Invalid response")
            }
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw SwapAndPayClient.EndpointError.message("Cannot parse response")
            }
            
            if httpResponse.statusCode >= 400 {
                // evaluate error
                if let errorMsg = jsonObject["message"] as? String {
                    // insufficient amount
                    var errorMsgConverted = errorMsg
                    if errorMsg.contains("Amount is too low for bridge, try at least") {
                        if let value = errorMsg.split(separator: "Amount is too low for bridge, try at least ").last, let valueInt = Int(value) {
                            let zecAmount = NSDecimalNumber(decimal: Decimal(valueInt) / Decimal(Zatoshi.Constants.oneZecInZatoshi))
                            
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            formatter.minimumFractionDigits = 2
                            formatter.maximumFractionDigits = 8
                            formatter.usesGroupingSeparator = false
                            formatter.locale = Locale.current
                            let localeValue = formatter.string(from: zecAmount) ?? "\(zecAmount)"
                            
                            errorMsgConverted = "Amount is too low for bridge, try at least \(localeValue) ZEC."
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
                  let timeEstimate = quote["timeEstimate"] as? Int,
                  let amountIn = Int64(amountInString),
                  let minAmountIn = Int64(minAmountInString),
                  let amountOutInt = Int64(amountOutString),
                  let amountInUsd = amountInUsdString.localeUsd,
                  let amountOutUsd = amountOutUsdString.localeUsd else {
                throw SwapAndPayClient.EndpointError.message("Parse of the quote failed.")
            }
            
            return SwapQuote(
                depositAddress: depositAddress,
                amountIn: amountIn,
                amountInUsd: amountInUsd,
                minAmountIn: minAmountIn,
                amountOut: Decimal(amountOutInt) / Decimal(pow(10.0, Double(toAsset.decimals))),
                amountOutUsd: amountOutUsd,
                timeEstimate: TimeInterval(timeEstimate)
            )
        }
    )
}
