//
//  Near1ClickLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-15-2025.
//

import Foundation
import Network
import Combine
import ComposableArchitecture

extension Near1ClickClient: DependencyKey {
    public static let liveValue = Self(
        tokens: {
            guard let url = URL(string: "https://1click.chaindefuser.com/v0/tokens") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw URLError(.cannotParseResponse)
            }

            let chainTokens = jsonObject.compactMap { dict -> ChainToken? in
                guard let chain = dict["blockchain"] as? String else {
                    return nil
                }

                guard let symbol = dict["symbol"] as? String else {
                    return nil
                }
                
                return ChainToken(chain: chain, token: symbol)
            }
            
            return Set(chainTokens)
        }
    )
}
