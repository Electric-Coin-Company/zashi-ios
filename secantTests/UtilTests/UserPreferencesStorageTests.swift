//
//  UserPreferencesStorageTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 22.03.2022.
//

import XCTest
@testable import secant_testnet
import Combine

class UserPreferencesStorageTests: XCTestCase {
    private var cancellables: [AnyCancellable] = []
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    var storage: UserPreferencesStorage!

    override func setUp() {
        super.setUp()
        
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
        storage.removeAll()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    override func tearDown() {
        super.tearDown()
        storage.removeAll()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
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

    func testAppSessionFrom_setNewValue() throws {
        storage.setActiveAppSessionFrom(87654321.0)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(87654321.0, storage.activeAppSessionFrom, "User Preferences: `activeAppSessionFrom` default doesn't match.")
    }

    func testConvertedCurrency_setNewValue() throws {
        storage.setCurrency("CZK")
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual("CZK", storage.currency, "User Preferences: `currency` default doesn't match.")
    }

    func testFiatConvertion_setNewValue() throws {
        storage.setIsFiatConverted(false)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(false, storage.isFiatConverted, "User Preferences: `isFiatConverted` default doesn't match.")
    }

    func testRecoveryPhraseTestCompleted_setNewValue() throws {
        storage.setIsRecoveryPhraseTestCompleted(false)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(false, storage.isRecoveryPhraseTestCompleted, "User Preferences: `isRecoveryPhraseTestCompleted` default doesn't match.")
    }

    func testSessionAutoshielded_setNewValue() throws {
        storage.setIsSessionAutoshielded(true)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(true, storage.isSessionAutoshielded, "User Preferences: `isSessionAutoshielded` default doesn't match.")
    }

    // MARK: - Mocked user defaults vs. default values

    func testAppSessionFrom_mocked() throws {
        let mockedUD = WrappedUserDefaults(
            objectForKey: { _ in 87654321.0 },
            remove: { _ in .none },
            setValue: { _, _ in .none },
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
        let mockedUD = WrappedUserDefaults(
            objectForKey: { _ in "CZK" },
            remove: { _ in .none },
            setValue: { _, _ in .none },
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
        let mockedUD = WrappedUserDefaults(
            objectForKey: { _ in false },
            remove: { _ in .none },
            setValue: { _, _ in .none },
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
        let mockedUD = WrappedUserDefaults(
            objectForKey: { _ in false },
            remove: { _ in .none },
            setValue: { _, _ in .none },
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
        let mockedUD = WrappedUserDefaults(
            objectForKey: { _ in true },
            remove: { _ in .none },
            setValue: { _, _ in .none },
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
    
    func testRemoveAll() throws {
        guard let userDefaults = UserDefaults.init(suiteName: "test") else {
            XCTFail("User Preferences: UserDefaults.init(suiteName: \"test\") failed to initialize")
            return
        }

        // fill in the data
        UserPreferencesStorage.Constants.allCases.forEach {
            userDefaults.set("anyValue", forKey: $0.rawValue)
        }

        // remove it
        storage?.removeAll()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)

        // check the presence
        UserPreferencesStorage.Constants.allCases.forEach {
            XCTAssertNil(
                userDefaults.object(forKey: $0.rawValue),
                "User Preferences: key \($0.rawValue) should be removed but it's still present in User Defaults"
            )
        }
    }
}
