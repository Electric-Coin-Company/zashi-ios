//
//  WrappedDerivationTool.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.04.2022.
//

import Foundation
import ZcashLightClientKit

// swiftlint:disable identifier_name
struct WrappedDerivationTool {
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
    let deriveSpendingKeys: ([UInt8], Int) throws -> [String]
    
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
    let isValidZcashAddress: (String) throws -> Bool
}

extension WrappedDerivationTool {
    public static func live(derivationTool: DerivationTool = DerivationTool(networkType: .mainnet)) -> Self {
        Self(
            deriveViewingKeys: { seed, numberOfAccounts in
                try derivationTool.deriveViewingKeys(seed: seed, numberOfAccounts: numberOfAccounts)
            },
            deriveViewingKey: { spendingKey in
                try derivationTool.deriveViewingKey(spendingKey: spendingKey)
            },
            deriveSpendingKeys: { seed, numberOfAccounts in
                try derivationTool.deriveSpendingKeys(seed: seed, numberOfAccounts: numberOfAccounts)
            },
            deriveShieldedAddress: { seed, accountIndex in
                try derivationTool.deriveShieldedAddress(seed: seed, accountIndex: accountIndex)
            },
            deriveShieldedAddressFromViewingKey: { viewingKey in
                try derivationTool.deriveShieldedAddress(viewingKey: viewingKey)
            },
            deriveTransparentAddress: { seed, account, index in
                try derivationTool.deriveTransparentAddress(seed: seed, account: account, index: index)
            },
            deriveUnifiedViewingKeysFromSeed: { seed, numberOfAccounts in
                try derivationTool.deriveUnifiedViewingKeysFromSeed(seed, numberOfAccounts: numberOfAccounts)
            },
            deriveUnifiedAddressFromUnifiedViewingKey: { uvk in
                try derivationTool.deriveUnifiedAddressFromUnifiedViewingKey(uvk)
            },
            deriveTransparentAddressFromPublicKey: { pubkey in
                try derivationTool.deriveTransparentAddressFromPublicKey(pubkey)
            },
            deriveTransparentPrivateKey: { seed, account, index in
                try derivationTool.deriveTransparentPrivateKey(seed: seed, account: account, index: index)
            },
            deriveTransparentAddressFromPrivateKey: { tsk in
                try derivationTool.deriveTransparentAddressFromPrivateKey(tsk)
            },
            isValidExtendedViewingKey: { extvk in
                try derivationTool.isValidExtendedViewingKey(extvk)
            },
            isValidTransparentAddress: { tAddress in
                try derivationTool.isValidTransparentAddress(tAddress)
            },
            isValidShieldedAddress: { zAddress in
                try derivationTool.isValidShieldedAddress(zAddress)
            },
            isValidZcashAddress: { address in
                try derivationTool.isValidTransparentAddress(address) ? true :
                try derivationTool.isValidShieldedAddress(address) ? true : false
            }
        )
    }
}
