//
//  secantTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 7/29/21.
//

import XCTest
@testable import secant_testnet

class SecantTests: XCTestCase {
    func testSubscriptRepresentation() throws {
        XCTAssertEqual(Int(0).superscriptRepresentation, "\u{2070}")
        XCTAssertEqual(Int(1).superscriptRepresentation, "\u{00B9}")
        XCTAssertEqual(Int(11).superscriptRepresentation, "\u{00B9}\u{00B9}")
        XCTAssertEqual(Int(111).superscriptRepresentation, "\u{00B9}\u{00B9}\u{00B9}")
        XCTAssertEqual(Int(2).superscriptRepresentation, "\u{00B2}")
        XCTAssertEqual(Int(22).superscriptRepresentation, "\u{00B2}\u{00B2}")
        XCTAssertEqual(Int(222).superscriptRepresentation, "\u{00B2}\u{00B2}\u{00B2}")
        XCTAssertEqual(Int(12).superscriptRepresentation, "\u{00B9}\u{00B2}")
        XCTAssertEqual(Int(3).superscriptRepresentation, "\u{00B3}")
        XCTAssertEqual(Int(33).superscriptRepresentation, "\u{00B3}\u{00B3}")
        XCTAssertEqual(Int(333).superscriptRepresentation, "\u{00B3}\u{00B3}\u{00B3}")
        XCTAssertEqual(Int(123).superscriptRepresentation, "\u{00B9}\u{00B2}\u{00B3}")
        XCTAssertEqual(Int(4).superscriptRepresentation, "\u{2074}")
        XCTAssertEqual(Int(5).superscriptRepresentation, "\u{2075}")
        XCTAssertEqual(Int(6).superscriptRepresentation, "\u{2076}")
        XCTAssertEqual(Int(7).superscriptRepresentation, "\u{2077}")
        XCTAssertEqual(Int(8).superscriptRepresentation, "\u{2078}")
        XCTAssertEqual(Int(9).superscriptRepresentation, "\u{2079}")
        XCTAssertEqual(
            Int(10).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(0).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(100).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(0).superscriptRepresentation + Int(0).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(11).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(1).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(12).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(2).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(13).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(3).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(14).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(4).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(15).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(5).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(16).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(6).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(17).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(7).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(18).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(8).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(19).superscriptRepresentation,
            Int(1).superscriptRepresentation + Int(9).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(20).superscriptRepresentation,
            Int(2).superscriptRepresentation + Int(0).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(21).superscriptRepresentation,
            Int(2).superscriptRepresentation + Int(1).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(22).superscriptRepresentation,
            Int(2).superscriptRepresentation + Int(2).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(23).superscriptRepresentation,
            Int(2).superscriptRepresentation + Int(3).superscriptRepresentation
        )
        XCTAssertEqual(
            Int(24).superscriptRepresentation,
            Int(2).superscriptRepresentation + Int(4).superscriptRepresentation
        )
    }
}
