//
//  RecoveryPhraseStorage.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/10/2022.
//

import Foundation
import MnemonicSwift

/// Zcash implementation of the keychain that is not universal but designed to deliver functionality needed by the wallet itself.
/// All the APIs should be thread safe according to official doc:
/// https://developer.apple.com/documentation/security/certificate_key_and_trust_services/working_with_concurrency?language=objc
// swiftlint:disable convenience_type
final class RecoveryPhraseStorage {
    enum Constants {
        static let zcashStoredWallet = "zcashStoredWallet"
        /// Versioning of the stored data
        static let zcashKeychainVersion = 1
    }

    enum KeychainError: Error, Equatable {
        case decoding
        case duplicate
        case encoding
        case noDataFound
        case unknown(OSStatus)
        case unsupportedVersion(Int)
        case unsupportedLanguage(MnemonicLanguageType)
    }
    
    // MARK: - Codable helpers
    
    static func decode<T: Decodable>(json: Data, as clazz: T.Type) throws -> T? {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: json)
            return data
        } catch {
            throw KeychainError.decoding
        }
    }

    static func encode<T: Codable>(object: T) throws -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(object)
        } catch {
            throw KeychainError.encoding
        }
    }
    
    // MARK: - Query Helpers

    static func baseQuery(forAccount account: String = "", andKey forKey: String) -> [String: Any] {
        let query:[ String: AnyObject ] = [
            /// Uniquely identify this keychain accessor
            kSecAttrService as String: forKey as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            /// The data in the keychain item can be accessed only while the device is unlocked by the user.
            /// This is recommended for items that need to be accessible only while the application is in the foreground.
            /// Items with this attribute do not migrate to a new device.
            /// Thus, after restoring from a backup of a different device, these items will not be present.
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        return query
    }
    
    static func restoreQuery(forAccount account: String = "", andKey forKey: String) -> [String: Any] {
        var query = baseQuery(forAccount: account, andKey: forKey)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnRef as String] = kCFBooleanFalse
        query[kSecReturnPersistentRef as String] = kCFBooleanFalse
        query[kSecReturnAttributes as String] = kCFBooleanFalse
        
        return query
    }
}

// MARK: - Recovery Phrase Helper Functions

private extension RecoveryPhraseStorage {
    func setWallet(_ wallet: StoredWallet) throws {
        guard let data = try RecoveryPhraseStorage.encode(object: wallet) else {
            throw KeychainError.encoding
        }
        
        try setData(data, forKey: Constants.zcashStoredWallet)
    }

    func wallet() throws -> StoredWallet {
        guard let data = data(forKey: Constants.zcashStoredWallet) else {
            throw KeychainError.noDataFound
        }
        
        guard let wallet = try RecoveryPhraseStorage.decode(json: data, as: StoredWallet.self) else {
            throw KeychainError.decoding
        }
        
        guard wallet.version == Constants.zcashKeychainVersion else {
            throw KeychainError.unsupportedVersion(wallet.version)
        }
        
        return wallet
    }

    /// Use carefully:  Deletes seed phrase from the keychain!!!
    @discardableResult
    func deleteWallet() -> Bool {
        deleteData(forKey: Constants.zcashStoredWallet)
    }
    
    /// Restore data for key
    func data(
        forKey: String,
        account: String = ""
    ) -> Data? {
        let query = RecoveryPhraseStorage.restoreQuery(forAccount: account, andKey: forKey)

        var result: AnyObject?
        _ = SecItemCopyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    /// Use carefully:  Deletes data for key
    func deleteData(
        forKey: String,
        account: String = ""
    ) -> Bool {
        let query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)

        let status = SecItemDelete(query as CFDictionary)

        return status == noErr
    }
    
    /// Store data for key
    func setData(
        _ data: Data,
        forKey: String,
        account: String = ""
    ) throws {
        var query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)
        query[kSecValueData as String] = data as AnyObject

        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicate
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    /// Use carefully:  Update data for key
    func updateData(
        _ data: Data,
        forKey: String,
        account: String = ""
    ) throws {
        let query = RecoveryPhraseStorage.baseQuery(forAccount: account, andKey: forKey)
        
        let attributes:[ String: AnyObject ] = [
            kSecValueData as String: data as AnyObject
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noDataFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}

// MARK: - KeyStoring

extension RecoveryPhraseStorage: KeyStoring {
    func importRecoveryPhrase(bip39 phrase: String, birthday: BlockHeight?, language: MnemonicLanguageType = .english) throws {
        // Future-proof of the bundle to potentialy avoid migration. We enforce english mnemonic.
        guard language == .english else {
            throw KeyStoringError.unsupportedLanguage(language)
        }
        
        do {
            let wallet = StoredWallet(
                birthday: birthday,
                language: language,
                seedPhrase: phrase,
                version: Constants.zcashKeychainVersion
            )
            
            try setWallet(wallet)
        } catch KeychainError.duplicate {
            throw KeyStoringError.alreadyImported
        } catch {
            throw KeyStoringError.storageError(error)
        }
    }
    
    func exportWallet() throws -> StoredWallet {
        do {
            return try wallet()
        } catch KeychainError.noDataFound, KeychainError.decoding {
            throw KeyStoringError.uninitializedWallet
        } catch KeychainError.unsupportedVersion(let version) {
            throw KeyStoringError.unsupportedVersion(version)
        } catch {
            throw KeyStoringError.storageError(error)
        }
    }
    
    func areKeysPresent() -> Bool {
        do {
            _ = try exportWallet()
        } catch KeyStoringError.uninitializedWallet {
            return false
        } catch {
            // TODO: - report & log error.localizedDescription
            return false
        }
        
        return true
    }
    
    func updateBirthday(_ height: BlockHeight) throws {
        do {
            var wallet = try exportWallet()
            wallet.birthday = height
            
            guard let data = try RecoveryPhraseStorage.encode(object: wallet) else {
                throw KeychainError.encoding
            }

            try updateData(data, forKey: Constants.zcashStoredWallet)
        } catch {
            throw error
        }
    }
    
    func nukeWallet() {
        deleteWallet()
    }
}
