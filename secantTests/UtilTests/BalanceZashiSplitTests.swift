//
//  BalanceZashiSplitTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 10.11.2023.
//

import XCTest
import Utils
import ZcashLightClientKit

final class BalanceZashiSplitTests: XCTestCase {
    func testNonePrefixSplit() throws {
        let balance = Zatoshi(25_793_456)
        
        let balanceSplit = BalanceZashiSplit(balance: balance)
        
        XCTAssertEqual(balanceSplit.main, "0.257")
        XCTAssertEqual(balanceSplit.rest, "93456")
    }
    
    func testPlusPrefixSplit() throws {
        let balance = Zatoshi(25_793_456)
        
        let balanceSplit = BalanceZashiSplit(balance: balance, prefixSymbol: .plus)
        
        XCTAssertEqual(balanceSplit.main, "+0.257")
        XCTAssertEqual(balanceSplit.rest, "93456")
    }
    
    func testMinusPrefixSplit() throws {
        let balance = Zatoshi(25_793_456)

        let balanceSplit = BalanceZashiSplit(balance: balance, prefixSymbol: .minus)
        
        XCTAssertEqual(balanceSplit.main, "-0.257")
        XCTAssertEqual(balanceSplit.rest, "93456")
    }
}
