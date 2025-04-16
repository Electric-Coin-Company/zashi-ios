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
    
    public func threeDecimalsZashiFormatted() -> String {
        let numberFormatter = NumberFormatter.zcashNumberFormatter
        numberFormatter.minimumFractionDigits = 3
        
        let balance = Zatoshi(
            (self.amount / 100_000) * 100_000
        )
        
        return numberFormatter.string(from: balance.decimalValue.roundedZec) ?? ""
    }
    
    public func atLeastThreeDecimalsZashiFormatted() -> String {
        let numberFormatter = NumberFormatter.zcashNumberFormatter
        numberFormatter.minimumFractionDigits = 3

        return numberFormatter.string(from: decimalValue.roundedZec) ?? ""
    }
}
