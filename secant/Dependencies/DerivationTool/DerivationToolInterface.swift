//
//  DerivationToolInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    var derivationTool: DerivationToolClient {
        get { self[DerivationToolClient.self] }
        set { self[DerivationToolClient.self] = newValue }
    }
}

// swiftlint:disable identifier_name
struct DerivationToolClient {
    /**
    Given a seed and a number of accounts, return the associated viewing keys.
     
    - Parameter seed: the seed from which to derive viewing keys.
    - Parameter numberOfAccounts: the number of accounts to use. Multiple accounts are not fully
    supported so the default value of 1 is recommended.
     
    - Returns: the viewing keys that correspond to the seed, formatted as Strings.
    */
    let deriveViewingKeys: ([UInt8], Int) throws -> [String]
    
    /**
    Given a spending key, return the associated viewing key.
     
    - Parameter spendingKey: the key from which to derive the viewing key.
     
    - Returns: the viewing key that corresponds to the spending key.
    */
    let deriveViewingKey: (String) throws -> String
    
    /**
    Given a seed and a number of accounts, return the associated spending keys.
     
    - Parameter seed: the seed from which to derive spending keys.
    - Parameter numberOfAccounts: the number of accounts to use. Multiple accounts are not fully
    supported so the default value of 1 is recommended.
     
    - Returns: the spending keys that correspond to the seed, formatted as Strings.
    */
    var deriveSpendingKeys: ([UInt8], Int) throws -> [String]
    
    /**
    Given a seed and account index, return the associated address.
     
    - Parameter seed: the seed from which to derive the address.
    - Parameter accountIndex: the index of the account to use for deriving the address. Multiple
    accounts are not fully supported so the default value of 1 is recommended.
     
    - Returns: the address that corresponds to the seed and account index.
    */
    let deriveShieldedAddress: ([UInt8], Int) throws -> String
    
    /**
    Given a viewing key string, return the associated address.
     
    - Parameter viewingKey: the viewing key to use for deriving the address. The viewing key is tied to
    a specific account so no account index is required.
     
    - Returns: the address that corresponds to the viewing key.
    */
    let deriveShieldedAddressFromViewingKey: (String) throws -> String
    
    /**
    Given a viewing key string, return the associated address.
     
    - Parameter seed: the seed from which to derive the address.
    - Parameter account: the account to use for deriving the address.
    - Parameter index: the index to use for deriving the address.
     
    - Returns: the address that corresponds to the seed.
    */
    let deriveTransparentAddress: ([UInt8], Int, Int) throws -> String
    
    /**
    Given a viewing key string, return the associated address.
     
    - Parameter seed: the seed from which to derive spending keys.
    - Parameter numberOfAccounts: the number of accounts to use. Multiple accounts are not fully
    supported so the default value of 1 is recommended.
     
    - Returns: the address that corresponds to the seed.
    */
    let deriveUnifiedViewingKeysFromSeed: ([UInt8], Int) throws -> [UnifiedViewingKey]
    
    /**
    Derives a Unified Address from a Unified Viewing Key
    */
    let deriveUnifiedAddressFromUnifiedViewingKey: (UnifiedViewingKey) throws -> UnifiedAddress
    
    /**
    Derives a Transparent Address from a Public Key
    */
    let deriveTransparentAddressFromPublicKey: (String) throws -> String
    
    /**
    Derives the transparent funds private key from the given seed
    - Throws:
    -  KeyDerivationErrors.derivationError with the underlying error when it fails
    - KeyDerivationErrors.unableToDerive when there's an unknown error
    */
    let deriveTransparentPrivateKey: ([UInt8], Int, Int) throws -> String
    
    /**
    Derives the transparent address from a WIF Private Key
    - Throws:
    - KeyDerivationErrors.derivationError with the underlying error when it fails
    - KeyDerivationErrors.unableToDerive when there's an unknown error
    */
    let deriveTransparentAddressFromPrivateKey: (String) throws -> String
    
    /**
    Checks validity of the extended viewing key.
    */
    let isValidExtendedViewingKey: (String) throws -> Bool
    
    /**
    Checks validity of the transparent address.
    */
    let isValidTransparentAddress: (String) throws -> Bool
    
    /**
    Checks validity of the shielded address.
    */
    let isValidShieldedAddress: (String) throws -> Bool
    
    /**
    Checks if given address is a valid zcash address.
    */
    var isValidZcashAddress: (String) throws -> Bool
}
