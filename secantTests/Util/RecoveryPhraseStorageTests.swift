//
//  RecoveryPhraseStorageTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 10.03.2022.
//

import XCTest
import MnemonicSwift
@testable import secant_testnet

extension KeyStoringError {
    var debugValue: String {
        switch self {
        case .alreadyImported: return "alreadyImported"
        case .uninitializedWallet: return "uninitializedWallet"
        case .storageError: return "storageError"
        case .unsupportedVersion: return "unsupportedVersion"
        case .unsupportedLanguage: return "unsupportedLanguage"
        }
    }
}

class RecoveryPhraseStorageTests: XCTestCase {
    let birthday = BlockHeight(12345678)
    let seedPhrase = "one two three"
    let language = MnemonicLanguageType.english
    var storage: RecoveryPhraseStorage?

    override func setUp() {
        super.setUp()
        storage = RecoveryPhraseStorage()
        deleteData(forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
    }
    
    override func tearDown() {
        super.tearDown()
        storage = nil
    }
    
    func testWalletStoredSucessfuly() throws {
        do {
            try storage?.importRecoveryPhrase(bip39: seedPhrase, birthday: birthday)
            guard let data = data(forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet) else {
                return XCTFail("Keychain: no data found for key: `zcashStoredWallet`.")
            }
            
            guard let walletReceived = try RecoveryPhraseStorage.decode(json: data, as: StoredWallet.self) else {
                return XCTFail("Keychain: `walletReceived` can't be decoded.")
            }
            
            XCTAssertEqual(birthday, walletReceived.birthday, "Keychain: stored birthday and retrieved one must be the same.")
            XCTAssertEqual(seedPhrase, walletReceived.seedPhrase, "Keychain: stored seed phrase and retrieved one must be the same.")
        } catch let err {
            XCTFail("Keychain: no error is expected for `testWalletStoredSucessfuly` but received. \(err)")
        }
    }

    func testWalletDuplicate() throws {
        do {
            try storage?.importRecoveryPhrase(bip39: seedPhrase, birthday: birthday)
            try storage?.importRecoveryPhrase(bip39: seedPhrase, birthday: birthday)
            
            XCTFail("Keychain: `testRecoveryPhraseDuplicate` is expected to throw a `duplicate` error but passed instead.")
        } catch {
            guard let error = error as? KeyStoringError else {
                XCTFail("Keychain: the error is expected to be KeyStoringError but it's \(error).")
                
                return
            }
            
            XCTAssertEqual(
                error.debugValue,
                KeyStoringError.alreadyImported.debugValue,
                "Keychain: error must be .alreadyImported but it's \(error)."
            )
        }
    }

    func testUninitializedWallet() throws {
        do {
            _ = try storage?.exportWallet()
            
            XCTFail("Keychain: `testUninitializedWallet` should fail but received some wallet.")
        } catch {
            guard let error = error as? KeyStoringError else {
                return XCTFail("Keychain: the error is expected to be KeyStoringError but it's \(error).")
            }

            XCTAssertEqual(error.debugValue, KeyStoringError.uninitializedWallet.debugValue, "Keychain: error must be .uninitializedWallet")
        }
    }
    
    func testDeleteWallet() throws {
        do {
            let wallet = StoredWallet(
                birthday: birthday,
                language: language,
                seedPhrase: seedPhrase,
                version: RecoveryPhraseStorage.Constants.zcashKeychainVersion
            )
            
            guard let walletData = try RecoveryPhraseStorage.encode(object: wallet) else {
                return XCTFail("`testDeleteWallet` encoding `walletData` failed.")
            }

            do {
                try setData(walletData, forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
            } catch {
                XCTFail("`testDeleteWallet` storing `walletData` failed.")
            }

            storage?.nukeWallet()
            
            let data = data(forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
            
            XCTAssertEqual(data, nil, "Keychain: keychain is expected to not find anything for key `zcashStoredWallet` but received some data.")
        }
    }
    
    func testUpdateBirthdayOverNil() throws {
        let wallet = StoredWallet(
            birthday: nil,
            language: language,
            seedPhrase: seedPhrase,
            version: RecoveryPhraseStorage.Constants.zcashKeychainVersion
        )
        
        guard let walletData = try RecoveryPhraseStorage.encode(object: wallet) else {
            return XCTFail("`testUpdateBirthdayOverNil` encoding `walletData` failed.")
        }

        do {
            try setData(walletData, forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
        } catch {
            XCTFail("`testUpdateBirthdayOverNil` storing `walletData` failed.")
        }

        do {
            try storage?.updateBirthday(birthday)
            guard let data = data(forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet) else {
                return XCTFail("Keychain: no data found for key: `zcashStoredWallet`.")
            }
            
            guard let walletReceived = try RecoveryPhraseStorage.decode(json: data, as: StoredWallet.self) else {
                return XCTFail("Keychain: `walletReceived` can't be decoded.")
            }
            
            XCTAssertEqual(birthday, walletReceived.birthday, "Keychain: stored birthday and retrieved one must be the same.")
            XCTAssertEqual(seedPhrase, walletReceived.seedPhrase, "Keychain: stored seed phrase and retrieved one must be the same.")
        } catch let err {
            XCTFail("Keychain: no error is expected for `testUpdateBirthdayOverNil` but received. \(err)")
        }
    }

    func testUpdateBirthdayOverSomeBirthday() throws {
        let wallet = StoredWallet(
            birthday: birthday,
            language: language,
            seedPhrase: seedPhrase,
            version: RecoveryPhraseStorage.Constants.zcashKeychainVersion
        )
        let newBirthday = BlockHeight(87654321)
        
        guard let walletData = try RecoveryPhraseStorage.encode(object: wallet) else {
            return XCTFail("`testUpdateBirthdayOverSomeBirthday` encoding `walletData` failed.")
        }

        do {
            try setData(walletData, forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
        } catch {
            XCTFail("`testUpdateBirthdayOverSomeBirthday` storing `walletData` failed.")
        }

        do {
            try storage?.updateBirthday(newBirthday)
            guard let data = data(forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet) else {
                return XCTFail("Keychain: no data found for key: `zcashStoredWallet`.")
            }
            
            guard let walletReceived = try RecoveryPhraseStorage.decode(json: data, as: StoredWallet.self) else {
                return XCTFail("Keychain: `walletReceived` can't be decoded.")
            }
            
            XCTAssertEqual(newBirthday, walletReceived.birthday, "Keychain: stored birthday and retrieved one must be the same.")
            XCTAssertEqual(seedPhrase, walletReceived.seedPhrase, "Keychain: stored seed phrase and retrieved one must be the same.")
        } catch let err {
            XCTFail("Keychain: no error is expected for `testUpdateBirthdayOverNil` but received. \(err)")
        }
    }
    
    func testUnsupportedVersion() throws {
        let wallet = StoredWallet(
            birthday: birthday,
            language: language,
            seedPhrase: seedPhrase,
            /// older version
            version: RecoveryPhraseStorage.Constants.zcashKeychainVersion - 1
        )
        
        guard let walletData = try RecoveryPhraseStorage.encode(object: wallet) else {
            return XCTFail("`testUnsupportedVersion` encoding `walletData` failed.")
        }

        do {
            try setData(walletData, forKey: RecoveryPhraseStorage.Constants.zcashStoredWallet)
        } catch {
            XCTFail("`testUnsupportedVersion` storing `walletData` failed.")
        }
        
        do {
            _ = try storage?.exportWallet()
            
            XCTFail("Keychain: `testUnsupportedVersion` should fail but received some wallet with correct version.")
        } catch KeyStoringError.unsupportedVersion(let version) {
            XCTAssertEqual(
                version + 1,
                RecoveryPhraseStorage.Constants.zcashKeychainVersion,
                "Keychain: version should be \(RecoveryPhraseStorage.Constants.zcashKeychainVersion) but stored version is \(version)"
            )
        } catch {
            XCTFail("Keychain: `testUnsupportedVersion` should fail with `unsupportedVersion` error but threw \(error).")
        }
    }
    
    func testUnsupportedLanguage() throws {
        do {
            try storage?.importRecoveryPhrase(bip39: seedPhrase, birthday: birthday, language: .chinese)
            
            XCTFail("Keychain: `testUnsupportedLanguage` should fail but imported chinese language.")
        } catch KeyStoringError.unsupportedLanguage(let languageToStore) {
            XCTAssertEqual(
                MnemonicLanguageType.chinese,
                languageToStore,
                "Keychain: language should be english but received \(languageToStore)"
            )
        } catch {
            XCTFail("Keychain: `testUnsupportedLanguage` should fail with `unsupportedLanguage` error but threw \(error).")
        }
    }
}

// MARK: - Misc

/// The followings methods are here purposely to not rely on `RecoveryPhraseStorage` in order to test functionality of JUST ONE method at a time
private extension RecoveryPhraseStorageTests {
    private func setData(
        account: String = "",
        _ data: Data,
        forKey: String
    ) throws {
        var query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)
        query[kSecValueData as String] = data as AnyObject

        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func data(
        forKey: String,
        account: String = ""
    ) -> Data? {
        let query = RecoveryPhraseStorage.restoreQuery(forAccount: account, andKey: forKey)

        var result: AnyObject?
        _ = SecItemCopyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    @discardableResult
    private func deleteData(
        forKey: String,
        account: String = ""
    ) -> Bool {
        let query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)

        let status = SecItemDelete(query as CFDictionary)

        return status == noErr
    }
    
    func updateData(
        _ data: Data,
        forKey: String,
        account: String = ""
    ) throws {
        let query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)
        
        let attributes:[ String: AnyObject ] = [
            kSecValueData as String: data as AnyObject
        ]

        _ = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }
}
