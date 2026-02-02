//
//  BalanceFormatter.swift
//
//
//  Created by Lukáš Korba on 19.10.2023.
//

import Foundation
import ZcashLightClientKit

extension Zatoshi {
    public func decimalZashiFormatted() -> String {
        NumberFormatter.zashiBalanceFormatter.string(from: decimalValue.roundedZec) ?? ""
    }
    
    public func decimalZashiFullFormatted() -> String {
        NumberFormatter.zcashNumberFormatter8FractionDigits.string(from: decimalValue.roundedZec) ?? ""
    }
    
    public func decimalZashiUSFormatted() -> String {
        NumberFormatter.zashiUSBalanceFormatter.string(from: decimalValue.roundedZec) ?? ""
    }

    public func decimalZashiTaxUSFormatted() -> String {
        NumberFormatter.zcashUSTaxNumberFormatter.string(from: decimalValue.roundedZec) ?? ""
    }

    public func threeDecimalsZashiFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.minimumFractionDigits = 3
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        
        let balance = Zatoshi(
            (self.amount / 100_000) * 100_000
        )
        
        return formatter.string(from: balance.decimalValue.roundedZec) ?? ""
    }
    
    public func atLeastThreeDecimalsZashiFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.minimumFractionDigits = 3
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true

        return formatter.string(from: decimalValue.roundedZec) ?? ""
    }
    
    public func roundToAvoidDustSpend() -> Zatoshi {
        let amountDouble = Double(amount)
        let roundedAmountDouble = roundl(amountDouble / 5_000) * 5_000

        return Zatoshi(Int64(roundedAmountDouble))
    }
}
