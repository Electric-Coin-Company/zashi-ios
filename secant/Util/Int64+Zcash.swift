//
//  Int64+Zcash.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.04.2022.
//

import Foundation

// TODO: Improve with decimals and zatoshi type, issue #272 (https://github.com/zcash/secant-ios-wallet/issues/272)
extension Int64 {
    func asHumanReadableZecBalance() -> Double {
        Double(self) / Double(100_000_000)
    }

    func asZecString() -> String {
        NumberFormatter.zcashFormatter.string(from: NSNumber(value: self.asHumanReadableZecBalance())) ?? ""
    }
}
