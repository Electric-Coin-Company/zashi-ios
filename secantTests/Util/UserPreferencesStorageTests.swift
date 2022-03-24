//
//  UserPreferencesStorageTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 22.03.2022.
//

import XCTest
@testable import secant_testnet

class UserPreferencesStorageTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var storage: UserPreferencesStorage!

    override func setUp() {
        super.setUp()
        storage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: .standard
        )
        storage.removeAll()
    }
    
    override func tearDown() {
        super.tearDown()
        storage = nil
    }
    
    func testAppSessionFrom_defaultValue() throws {
        XCTAssertEqual(12345678.0, storage.activeAppSessionFrom, "User Preferences: `activeAppSessionFrom` default doesn't match.")
    }

    func testConvertedCurrency_defaultValue() throws {
        XCTAssertEqual("USD", storage.currency, "User Preferences: `currency` default doesn't match.")
    }

    func testFiatConvertion_defaultValue() throws {
        XCTAssertEqual(true, storage.isFiatConverted, "User Preferences: `isFiatConverted` default doesn't match.")
    }

    func testRecoveryPhraseTestCompleted_defaultValue() throws {
        XCTAssertEqual(true, storage.isRecoveryPhraseTestCompleted, "User Preferences: `isRecoveryPhraseTestCompleted` default doesn't match.")
    }

    func testSessionAutoshielded_defaultValue() throws {
        XCTAssertEqual(false, storage.isSessionAutoshielded, "User Preferences: `isSessionAutoshielded` default doesn't match.")
    }

    func testRemoveAll() throws {
        let userDefaults = UserDefaults.standard

        // fill in the data
        UserPreferencesStorage.Constants.allCases.forEach {
            userDefaults.set("anyValue", forKey: $0.rawValue)
        }

        // remove it
        storage?.removeAll()

        // check the presence
        UserPreferencesStorage.Constants.allCases.forEach {
            XCTAssertNil(
                userDefaults.object(forKey: $0.rawValue),
                "User Preferences: key \($0.rawValue) should be removed but it's still present in User Defaults"
            )
        }
    }
}
