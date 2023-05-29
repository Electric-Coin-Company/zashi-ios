//
//  SensitiveData.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.02.2023.
//

import Foundation
import ZcashLightClientKit

// MARK: - Redactable Protocol

/// `Undescribable` comes from the SDK and it is a reliable and tested protocol ensuring custom
/// destriptions and dumps never print outs the exact value but `--redacted--` instead.
/// `Redactable` protocol is just a helper so we can let developers to see the sensitive data when
/// developing and debugging but production or release builds (even testflight) are set to redacted by default.
#if DEBUG
public protocol Redactable { }
#else
public protocol Redactable: Undescribable { }
#endif

// MARK: - Redactable Seed Phrase

/// Read-only redacted holder for a seed phrase.
public struct SeedPhrase: Codable, Equatable, Redactable {
    private let seedPhrase: String

    public init(_ seedPhrase: String) {
        self.seedPhrase = seedPhrase
    }
    
    /// This method returns seed phrase, all 24 words with no protection or support of `Redactable` protocol.
    /// Use it wisely and never log outcome of this method or share with anybody.
    public func value() -> String {
        seedPhrase
    }
}

// MARK: - Redactable Birthday

/// Read-only redacted holder for a birthday.
public struct Birthday: Codable, Equatable, Redactable {
    private let birthday: BlockHeight?

    public init(_ birthday: BlockHeight?) {
        self.birthday = birthday
    }

    /// This method returns birthday with no protection or support of `Redactable` protocol.
    /// Use it wisely and never log outcome of this method or share with anybody.
    public func value() -> BlockHeight? {
        birthday
    }
}

// MARK: - Redactable String

/// Redactable holder for a string.
public struct RedactableString: Equatable, Hashable, Redactable {
    public let data: String
    
    public init(_ data: String = "") { self.data = data }
}

/// Utility that converts a string to a redacted counterpart.
extension String {
    public var redacted: RedactableString { RedactableString(self) }
}

// MARK: - Redactable BlockHeight

/// Redactable holder for a block height.
public struct RedactableBlockHeight: Equatable, Redactable {
    public let data: BlockHeight

    public init(_ data: BlockHeight = -1) { self.data = data }
}

/// Utility that converts a block height to a redacted counterpart.
extension BlockHeight {
    public var redacted: RedactableBlockHeight { RedactableBlockHeight(self) }
}

// MARK: - Redactable WalletBalance

/// Redactable holder for a wallet balance.
public struct Balance: Equatable, Redactable {
    public let data: WalletBalance

    public init(_ data: WalletBalance = .zero) { self.data = data }
}

/// Utility that converts a string to a redacted counterpart.
extension WalletBalance {
    public var redacted: Balance { Balance(self) }
}

extension Balance {
    public static var zero: Balance {
        Self(WalletBalance(verified: .zero, total: .zero))
    }
}

// MARK: - Redactable Int64

/// Redactable holder for an Int64.
public struct RedactableInt64: Equatable, Redactable {
    public let data: Int64

    public init(_ data: Int64 = -1) { self.data = data }
}

/// Utility that converts a block height to a redacted counterpart.
extension Int64 {
    public var redacted: RedactableInt64 { RedactableInt64(self) }
}
