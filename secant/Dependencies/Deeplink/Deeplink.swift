//
//  Deeplink.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.06.2022.
//

import Foundation
import URLRouting
import ComposableArchitecture
import ZcashLightClientKit

struct Deeplink {
    enum Destination: Equatable {
        case home
        case send(amount: Int64, address: String, memo: String)
    }
    
    func resolveDeeplinkURL(_ url: URL, isValidZcashAddress: (String) throws -> Bool) throws -> Destination {
        // simplified format zcash:<address>
        // TODO: [#109] simplified for now until ZIP-321 is implememnted (https://github.com/zcash/secant-ios-wallet/issues/109)
        let address = url.absoluteString.replacingOccurrences(of: "zcash:", with: "")
        do {
            if try isValidZcashAddress(address) {
                return .send(amount: 0, address: address, memo: "")
            }
        }
        
        // regular URL format zcash://
        let appRouter = OneOf {
            // GET /home
            Route(.case(Destination.home)) {
                Path { "home" }
            }

            // GET /home/send?amount=:amount&address=:address&memo=:memo
            Route(.case(Destination.send(amount:address:memo:))) {
                Path { "home"; "send" }
                Query {
                    Field("amount", default: 0) { Int64.parser() }
                    Field("address", .string, default: "")
                    Field("memo", .string, default: "")
                }
            }
        }

        switch try appRouter.match(url: url) {
        case .home:
            return .home

        case let .send(amount, address, memo):
            return .send(amount: amount, address: address, memo: memo)
        }
    }
}
