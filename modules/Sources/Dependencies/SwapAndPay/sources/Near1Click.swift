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
}

extension Near1Click {
    public static let liveValue = Self(
        swapAssets: {
            guard let url = URL(string: "https://1click.chaindefuser.com/v0/tokens") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                _ = try await URLSession.shared.data(for: request)
            } catch {
                print("__LD \(error)")
            }
            
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
        }
    )
}

