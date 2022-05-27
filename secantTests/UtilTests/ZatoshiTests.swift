//
//  ZatoshiTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 26.05.2022.
//

import XCTest
@testable import secant_testnet

class ZatoshiTests: XCTestCase {
    func testLowerBound() throws {
        let number = Zatoshi(amount: -Zatoshi.Constants.maxZatoshi - 1)
        
        XCTAssertEqual(
            -Zatoshi.Constants.maxZatoshi,
            number.amount,
            "Zatoshi tests: `testLowerBound` the value is expected to be clamped to lower bound but it's \(number.amount)"
        )
    }

    func testUpperBound() throws {
        let number = Zatoshi(amount: Zatoshi.Constants.maxZatoshi + 1)

        XCTAssertEqual(
            Zatoshi.Constants.maxZatoshi,
            number.amount,
            "Zatoshi tests: `testUpperBound` the value is expected to be clamped to upper bound but it's \(number.amount)"
        )
    }
    
    func testAddingZatoshi() throws {
        let numberA1 = Zatoshi(amount: 100_000)
        let numberB1 = Zatoshi(amount: 200_000)
        let result1 = numberA1 + numberB1
        
        XCTAssertEqual(
            result1.amount,
            Zatoshi(amount: 300_000).amount,
            "Zatoshi tests: `testAddingZatoshi` the value is expected to be 300_000 but it's \(result1.amount)"
        )

        let numberA2 = Zatoshi(amount: -100_000)
        let numberB2 = Zatoshi(amount: 200_000)
        let result2 = numberA2 + numberB2
        
        XCTAssertEqual(
            result2.amount,
            Zatoshi(amount: 100_000).amount,
            "Zatoshi tests: `testAddingZatoshi` the value is expected to be 100_000 but it's \(result2.amount)"
        )
        
        let numberA3 = Zatoshi(amount: 100_000)
        let numberB3 = Zatoshi(amount: -200_000)
        let result3 = numberA3 + numberB3
        
        XCTAssertEqual(
            result3.amount,
            Zatoshi(amount: -100_000).amount,
            "Zatoshi tests: `testAddingZatoshi` the value is expected to be -100_000 but it's \(result3.amount)"
        )

        let number = Zatoshi(amount: Zatoshi.Constants.maxZatoshi)
        let result4 = number + number
        
        XCTAssertEqual(
            result4.amount,
            Zatoshi.Constants.maxZatoshi,
            "Zatoshi tests: `testAddingZatoshi` the value is expected to be clapmed to upper bound but it's \(result4.amount)"
        )
    }
    
    func testSubtractingZatoshi() throws {
        let numberA1 = Zatoshi(amount: 100_000)
        let numberB1 = Zatoshi(amount: 200_000)
        let result1 = numberA1 - numberB1
        
        XCTAssertEqual(
            result1.amount,
            Zatoshi(amount: -100_000).amount,
            "Zatoshi tests: `testSubtractingZatoshi` the value is expected to be -100_000 but it's \(result1.amount)"
        )

        let numberA2 = Zatoshi(amount: -100_000)
        let numberB2 = Zatoshi(amount: 200_000)
        let result2 = numberA2 - numberB2
        
        XCTAssertEqual(
            result2.amount,
            Zatoshi(amount: -300_000).amount,
            "Zatoshi tests: `testSubtractingZatoshi` the value is expected to be -300_000 but it's \(result2.amount)"
        )
        
        let numberA3 = Zatoshi(amount: 100_000)
        let numberB3 = Zatoshi(amount: -200_000)
        let result3 = numberA3 - numberB3
        
        XCTAssertEqual(
            result3.amount,
            Zatoshi(amount: 300_000).amount,
            "Zatoshi tests: `testSubtractingZatoshi` the value is expected to be 300_000 but it's \(result3.amount)"
        )

        let number = Zatoshi(amount: -Zatoshi.Constants.maxZatoshi)
        let result4 = number + number
        
        XCTAssertEqual(
            result4.amount,
            -Zatoshi.Constants.maxZatoshi,
            "Zatoshi tests: `testSubtractingZatoshi` the value is expected to be clapmed to lower bound but it's \(result4.amount)"
        )
    }
    
    func testHumanReadable() throws {
        // result of this division is 1.4285714285714285714285714285714285714
        let number = Zatoshi.from(decimal: Decimal(200.0 / 140.0))
        
        // IMPORTANT: the INTERNAL value of number is still 1.4285714285714285714285714285714285714!!!
        // but decimalString is rounding it to maximumFractionDigits set to be 8
        
        // We can't compare it to double value 1.42857143 (or even Decimal(1.42857143))
        // so we convert it to string, in that case we are prooving it to be rendered
        //    to the user exactly the way we want
        XCTAssertEqual(
            number.decimalString,
            "1.42857143",
            "Zatoshi tests: the value is expected to be 1.42857143 but it's \(number.decimalString)"
        )
    }

    func testUSDtoZecToUSD() throws {
        // The price of zec is $140, we want to send $200
        let usd2zec = NSDecimalNumber(decimal: 200.0 / 140.0)

        XCTAssertEqual(
            usd2zec.decimalString,
            "1.42857143",
            "Zatoshi tests: `testUSDtoZatoshiToUSD` the value is expected to be 1.42857143 but it's \(usd2zec.decimalString)"
        )
        
        // convert it back
        let zec2usd = NSDecimalNumber(decimal: usd2zec.decimalValue * 140.0)

        XCTAssertEqual(
            zec2usd.decimalString,
            "200",
            "Zatoshi tests: `testUSDtoZatoshiToUSD` the value is expected to be 200 but it's \(zec2usd.decimalString)"
        )
    }
    
    func testStringToZatoshi() throws {
        if let number = Zatoshi.from(decimalString: "200.0") {
            XCTAssertEqual(
                number.decimalString,
                "200",
                "Zatoshi tests: `testStringToZec` the value is expected to be 200 but it's \(number.decimalString)"
            )
        } else {
            XCTFail("Zatoshi tests: `testStringToZatoshi` failed to convert number.")
        }

        if let number = Zatoshi.from(decimalString: "0.02836478949923") {
            XCTAssertEqual(
                number.amount,
                2_836_479,
                "Zatoshi tests: the value is expected to be 2_836_478 but it's \(number.amount)"
            )
        } else {
            XCTFail("Zatoshi tests: `testStringToZatoshi` failed to convert number.")
        }
    }
}
