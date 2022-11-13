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

    override func setUp() async throws {
        try await super.setUp()
        
        guard let userDefaults = UserDefaults.init(suiteName: "test") else {
            XCTFail("UserPreferencesStorageTests: UserDefaults.init(suiteName: \"test\") failed to initialize")
            return
        }
        
        storage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: .live(userDefaults: userDefaults)
        )
        await storage.removeAll()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        await storage.removeAll()
        storage = nil
    }
    
    // MARK: - Default values in the live UserDefaults environment
    
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

    // MARK: - Set new values in the live UserDefaults environment

    func testAppSessionFrom_setNewValue() async throws {
        await storage.setActiveAppSessionFrom(87654321.0)

        XCTAssertEqual(87654321.0, storage.activeAppSessionFrom, "User Preferences: `activeAppSessionFrom` default doesn't match.")
    }

    func testConvertedCurrency_setNewValue() async throws {
        await storage.setCurrency("CZK")

        XCTAssertEqual("CZK", storage.currency, "User Preferences: `currency` default doesn't match.")
    }

    func testFiatConvertion_setNewValue() async throws {
        await storage.setIsFiatConverted(false)

        XCTAssertEqual(false, storage.isFiatConverted, "User Preferences: `isFiatConverted` default doesn't match.")
    }

    func testRecoveryPhraseTestCompleted_setNewValue() async throws {
        await storage.setIsRecoveryPhraseTestCompleted(false)

        XCTAssertEqual(false, storage.isRecoveryPhraseTestCompleted, "User Preferences: `isRecoveryPhraseTestCompleted` default doesn't match.")
    }

    func testSessionAutoshielded_setNewValue() async throws {
        await storage.setIsSessionAutoshielded(true)

        XCTAssertEqual(true, storage.isSessionAutoshielded, "User Preferences: `isSessionAutoshielded` default doesn't match.")
    }

    // MARK: - Mocked user defaults vs. default values

    func testAppSessionFrom_mocked() throws {
        let mockedUD = UserDefaultsClient(
            objectForKey: { _ in 87654321.0 },
            remove: { _ in },
            setValue: { _, _ in },
            synchronize: { true }
        )
        
        let mockedStorage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: mockedUD
        )

        XCTAssertEqual(87654321.0, mockedStorage.activeAppSessionFrom, "User Preferences: `activeAppSessionFrom` default doesn't match.")
    }

    func testConvertedCurrency_mocked() throws {
        let mockedUD = UserDefaultsClient(
            objectForKey: { _ in "CZK" },
            remove: { _ in },
            setValue: { _, _ in },
            synchronize: { true }
        )
        
        let mockedStorage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: mockedUD
        )

        XCTAssertEqual("CZK", mockedStorage.currency, "User Preferences: `currency` default doesn't match.")
    }

    func testFiatConvertion_mocked() throws {
        let mockedUD = UserDefaultsClient(
            objectForKey: { _ in false },
            remove: { _ in },
            setValue: { _, _ in },
            synchronize: { true }
        )
        
        let mockedStorage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: mockedUD
        )

        XCTAssertEqual(false, mockedStorage.isFiatConverted, "User Preferences: `isFiatConverted` default doesn't match.")
    }

    func testRecoveryPhraseTestCompleted_mocked() throws {
        let mockedUD = UserDefaultsClient(
            objectForKey: { _ in false },
            remove: { _ in },
            setValue: { _, _ in },
            synchronize: { true }
        )
        
        let mockedStorage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: mockedUD
        )

        XCTAssertEqual(false, mockedStorage.isRecoveryPhraseTestCompleted, "User Preferences: `isRecoveryPhraseTestCompleted` default doesn't match.")
    }

    func testSessionAutoshielded_mocked() throws {
        let mockedUD = UserDefaultsClient(
            objectForKey: { _ in true },
            remove: { _ in },
            setValue: { _, _ in },
            synchronize: { true }
        )
        
        let mockedStorage = UserPreferencesStorage(
            appSessionFrom: 12345678.0,
            convertedCurrency: "USD",
            fiatConvertion: true,
            recoveryPhraseTestCompleted: true,
            sessionAutoshielded: false,
            userDefaults: mockedUD
        )

        XCTAssertEqual(true, mockedStorage.isSessionAutoshielded, "User Preferences: `isSessionAutoshielded` default doesn't match.")
    }

    // MARK: - Remove all keys from the live UD environment
    
    func testRemoveAll() async throws {
        guard let userDefaults = UserDefaults.init(suiteName: "test") else {
            XCTFail("User Preferences: UserDefaults.init(suiteName: \"test\") failed to initialize")
            return
        }

        // fill in the data
        UserPreferencesStorage.Constants.allCases.forEach {
            userDefaults.set("anyValue", forKey: $0.rawValue)
        }

        // remove it
        await storage?.removeAll()

        // check the presence
        UserPreferencesStorage.Constants.allCases.forEach {
            XCTAssertNil(
                userDefaults.object(forKey: $0.rawValue),
                "User Preferences: key \($0.rawValue) should be removed but it's still present in User Defaults"
            )
        }
    }
}
