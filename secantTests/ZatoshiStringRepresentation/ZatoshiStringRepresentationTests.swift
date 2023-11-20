//
//  ZatoshiStringRepresentationTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 17.11.2023.
//

import XCTest
import ZcashLightClientKit
import BalanceFormatter
@testable import secant_testnet

final class ZatoshiStringRepresentationTests: XCTestCase {
    func testNonePrefixSplit() throws {
        let balance = Zatoshi(25_793_456)
        
        let zatoshiStringRepresentation = ZatoshiStringRepresentation(balance)
        
        XCTAssertEqual(zatoshiStringRepresentation.mostSignificantDigits, "0.257")
        XCTAssertEqual(zatoshiStringRepresentation.leastSignificantDigits, "93456")
    }
    
    func testPlusPrefixSplit() throws {
        let balance = Zatoshi(25_793_456)
        
        let zatoshiStringRepresentation = ZatoshiStringRepresentation(balance, prefixSymbol: .plus)
        
        XCTAssertEqual(zatoshiStringRepresentation.mostSignificantDigits, "+0.257")
        XCTAssertEqual(zatoshiStringRepresentation.leastSignificantDigits, "93456")
    }
    
    func testMinusPrefixSplit() throws {
        let balance = Zatoshi(25_793_456)

        let zatoshiStringRepresentation = ZatoshiStringRepresentation(balance, prefixSymbol: .minus)
        
        XCTAssertEqual(zatoshiStringRepresentation.mostSignificantDigits, "-0.257")
        XCTAssertEqual(zatoshiStringRepresentation.leastSignificantDigits, "93456")
    }}
