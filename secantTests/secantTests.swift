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
        XCTAssertEqual(UInt(0).superscriptRepresentation, "\u{2070}")
        XCTAssertEqual(UInt(1).superscriptRepresentation, "\u{00B9}")
        XCTAssertEqual(UInt(11).superscriptRepresentation, "\u{00B9}\u{00B9}")
        XCTAssertEqual(UInt(111).superscriptRepresentation, "\u{00B9}\u{00B9}\u{00B9}")
        XCTAssertEqual(UInt(2).superscriptRepresentation, "\u{00B2}")
        XCTAssertEqual(UInt(22).superscriptRepresentation, "\u{00B2}\u{00B2}")
        XCTAssertEqual(UInt(222).superscriptRepresentation, "\u{00B2}\u{00B2}\u{00B2}")
        XCTAssertEqual(UInt(12).superscriptRepresentation, "\u{00B9}\u{00B2}")
        XCTAssertEqual(UInt(3).superscriptRepresentation, "\u{00B3}")
        XCTAssertEqual(UInt(33).superscriptRepresentation, "\u{00B3}\u{00B3}")
        XCTAssertEqual(UInt(333).superscriptRepresentation, "\u{00B3}\u{00B3}\u{00B3}")
        XCTAssertEqual(UInt(123).superscriptRepresentation, "\u{00B9}\u{00B2}\u{00B3}")
        XCTAssertEqual(UInt(4).superscriptRepresentation, "\u{2074}")
        XCTAssertEqual(UInt(5).superscriptRepresentation, "\u{2075}")
        XCTAssertEqual(UInt(6).superscriptRepresentation, "\u{2076}")
        XCTAssertEqual(UInt(7).superscriptRepresentation, "\u{2077}")
        XCTAssertEqual(UInt(8).superscriptRepresentation, "\u{2078}")
        XCTAssertEqual(UInt(9).superscriptRepresentation, "\u{2079}")
        XCTAssertEqual(
            UInt(10).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(0).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(100).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(0).superscriptRepresentation + UInt(0).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(11).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(1).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(12).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(2).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(13).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(3).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(14).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(4).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(15).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(5).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(16).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(6).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(17).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(7).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(18).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(8).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(19).superscriptRepresentation,
            UInt(1).superscriptRepresentation + UInt(9).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(20).superscriptRepresentation,
            UInt(2).superscriptRepresentation + UInt(0).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(21).superscriptRepresentation,
            UInt(2).superscriptRepresentation + UInt(1).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(22).superscriptRepresentation,
            UInt(2).superscriptRepresentation + UInt(2).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(23).superscriptRepresentation,
            UInt(2).superscriptRepresentation + UInt(3).superscriptRepresentation
        )
        XCTAssertEqual(
            UInt(24).superscriptRepresentation,
            UInt(2).superscriptRepresentation + UInt(4).superscriptRepresentation
        )
    }
}
