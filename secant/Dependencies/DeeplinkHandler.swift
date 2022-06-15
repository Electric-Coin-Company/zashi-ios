//
//  DeeplinkHandler.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.06.2022.
//

import Foundation
import _URLRouting
import ComposableArchitecture
import ZcashLightClientKit

struct DeeplinkHandler {
    enum Deeplink {
        case home
        case send(amount: Int64, address: String, memo: String)
    }
    
    func resolveDeeplinkURL(_ url: URL, derivationTool: WrappedDerivationTool) throws -> Deeplink {
        // simplified format zcash:<address>
        // TODO: simplified for now until ZIP-321 is implememnted, issue 109 (https://github.com/zcash/secant-ios-wallet/issues/109)
        let address = url.absoluteString.replacingOccurrences(of: "zcash:", with: "")
        do {
            if try derivationTool.isValidZcashAddress(address) {
                return .send(amount: 0, address: address, memo: "")
            }
        }
        
        // regular URL format zcash://
        let appRouter = OneOf {
            // GET /home
            Route(.case(Deeplink.home)) {
                Path { "home" }
            }

            // GET /home/send?amount=:amount&address=:address&memo=:memo
            Route(.case(Deeplink.send(amount:address:memo:))) {
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
