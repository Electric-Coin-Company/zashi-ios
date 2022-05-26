//
//  Double+Zcash.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 06.05.2022.
//

import Foundation

// TODO: Improve with decimals and zatoshi type, issue #272 (https://github.com/zcash/secant-ios-wallet/issues/272)
extension Double {
    func asZec() -> Int64 {
        return Int64((self * 100_000_000).rounded())
    }

    func asZecString() -> String {
        NumberFormatter.zcashNumberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
