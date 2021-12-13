//
//  RecoveryFlowTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 10/29/21.
//

import XCTest
@testable import secant_testnet
class RecoveryPhraseBackupTests: XCTestCase {
    func testGiven24WordsBIP39ChunkItIntoQuarters() throws {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]
        let phrase = RecoveryPhrase(words: words)

        let chunks = phrase.toChunks()

        XCTAssertEqual(chunks.count, 4)
        XCTAssertEqual(chunks[0].startIndex, 1)
        XCTAssertEqual(chunks[0].words, ["bring", "salute", "thank", "require", "spirit", "toe"])
        XCTAssertEqual(chunks[1].startIndex, 7)
        XCTAssertEqual(chunks[2].startIndex, 13)
        XCTAssertEqual(chunks[3].startIndex, 19)
    }
}
