//
//  WalletStorage.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/10/2022.
//

import Foundation
import MnemonicSwift
import ZcashLightClientKit
import Utils

/// Zcash implementation of the keychain that is not universal but designed to deliver functionality needed by the wallet itself.
/// All the APIs should be thread safe according to official doc:
/// https://developer.apple.com/documentation/security/certificate_key_and_trust_services/working_with_concurrency?language=objc
struct WalletStorage {
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
    }

    enum WalletStorageError: Error {
        case alreadyImported
        case uninitializedWallet
        case storageError(Error)
        case unsupportedVersion(Int)
        case unsupportedLanguage(MnemonicLanguageType)
    }

    private let secItem: SecItemClient
    var zcashStoredWalletPrefix = ""
    
    init(secItem: SecItemClient) {
        self.secItem = secItem
    }

    func importWallet(
        bip39 phrase: String,
        birthday: BlockHeight?,
        language: MnemonicLanguageType = .english,
        hasUserPassedPhraseBackupTest: Bool = false
    ) throws {
        // Future-proof of the bundle to potentially avoid migration. We enforce english mnemonic.
        guard language == .english else {
            throw WalletStorageError.unsupportedLanguage(language)
        }

        let wallet = StoredWallet(
            language: language,
            seedPhrase: SeedPhrase(phrase),
            version: Constants.zcashKeychainVersion,
            birthday: Birthday(birthday),
            hasUserPassedPhraseBackupTest: hasUserPassedPhraseBackupTest
        )

        do {
            guard let data = try encode(object: wallet) else {
                throw KeychainError.encoding
            }
            
            try setData(data, forKey: Constants.zcashStoredWallet)
        } catch KeychainError.duplicate {
            throw WalletStorageError.alreadyImported
        } catch {
            throw WalletStorageError.storageError(error)
        }
    }
    
    func exportWallet() throws -> StoredWallet {
        guard let data = data(forKey: Constants.zcashStoredWallet) else {
            throw WalletStorageError.uninitializedWallet
        }
        
        guard let wallet = try decode(json: data, as: StoredWallet.self) else {
            throw WalletStorageError.uninitializedWallet
        }
        
        guard wallet.version == Constants.zcashKeychainVersion else {
            throw WalletStorageError.unsupportedVersion(wallet.version)
        }
        
        return wallet
    }
    
    func areKeysPresent() throws -> Bool {
        do {
            _ = try exportWallet()
        } catch {
            // TODO: [#219] - report & log error.localizedDescription, https://github.com/zcash/secant-ios-wallet/issues/219]
            throw error
        }
        
        return true
    }
    
    func updateBirthday(_ height: BlockHeight) throws {
        do {
            var wallet = try exportWallet()
            wallet.birthday = Birthday(height)
            
            guard let data = try encode(object: wallet) else {
                throw KeychainError.encoding
            }
            
            try updateData(data, forKey: Constants.zcashStoredWallet)
        } catch {
            throw error
        }
    }
    
    func markUserPassedPhraseBackupTest(_ flag: Bool = true) throws {
        do {
            var wallet = try exportWallet()
            wallet.hasUserPassedPhraseBackupTest = flag
            
            guard let data = try encode(object: wallet) else {
                throw KeychainError.encoding
            }
            
            try updateData(data, forKey: Constants.zcashStoredWallet)
        } catch {
            throw error
        }
    }
    
    func nukeWallet() {
        deleteData(forKey: Constants.zcashStoredWallet)
    }
    
    // MARK: - Wallet Storage Codable & Query helpers
    
    func decode<T: Decodable>(json: Data, as clazz: T.Type) throws -> T? {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: json)
            return data
        } catch {
            throw KeychainError.decoding
        }
    }

    func encode<T: Codable>(object: T) throws -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(object)
        } catch {
            throw KeychainError.encoding
        }
    }
    
    func baseQuery(forAccount account: String = "", andKey forKey: String) -> [String: Any] {
        let query: [String: AnyObject] = [
            /// Uniquely identify this keychain accessor
            kSecAttrService as String: (zcashStoredWalletPrefix + forKey) as AnyObject,
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
    
    func restoreQuery(forAccount account: String = "", andKey forKey: String) -> [String: Any] {
        var query = baseQuery(forAccount: account, andKey: forKey)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnRef as String] = kCFBooleanFalse
        query[kSecReturnPersistentRef as String] = kCFBooleanFalse
        query[kSecReturnAttributes as String] = kCFBooleanFalse
        
        return query
    }

    /// Restore data for key
    func data(
        forKey: String,
        account: String = ""
    ) -> Data? {
        let query = restoreQuery(forAccount: account, andKey: forKey)

        var result: AnyObject?
        _ = secItem.copyMatching(query as CFDictionary, &result)
        
        return result as? Data
    }
    
    /// Use carefully:  Deletes data for key
    @discardableResult
    func deleteData(
        forKey: String,
        account: String = ""
    ) -> Bool {
        let query = baseQuery(forAccount: account, andKey: forKey)

        let status = secItem.delete(query as CFDictionary)

        return status == noErr
    }
    
    /// Store data for key
    func setData(
        _ data: Data,
        forKey: String,
        account: String = ""
    ) throws {
        var query = baseQuery(forAccount: account, andKey: forKey)
        query[kSecValueData as String] = data as AnyObject

        var result: AnyObject?
        let status = secItem.add(query as CFDictionary, &result)
        
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
        let query = baseQuery(forAccount: account, andKey: forKey)
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject
        ]

        let status = secItem.update(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.noDataFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}
