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
/// A special build scheme `<...>-unredacted` is set to hold `UNREDACTED` flags.
#if UNREDACTED
protocol Redactable { }
#else
protocol Redactable: Undescribable { }
#endif

// MARK: - Redactable Seed Phrase

/// Read-only redacted holder for a seed phrase.
struct SeedPhrase: Codable, Equatable, Redactable {
    private let seedPhrase: String

    init(_ seedPhrase: String) {
        self.seedPhrase = seedPhrase
    }
    
    /// This method returns seed phrase, all 24 words with no protection or support of `Redactable` protocol.
    /// Use it wisely and never log outcome of this method or share with anybody.
    func value() -> String {
        seedPhrase
    }
}

// MARK: - Redactable Birthday

/// Read-only redacted holder for a birthday.
struct Birthday: Codable, Equatable, Redactable {
    private let birthday: BlockHeight?

    init(_ birthday: BlockHeight?) {
        self.birthday = birthday
    }

    /// This method returns birthday with no protection or support of `Redactable` protocol.
    /// Use it wisely and never log outcome of this method or share with anybody.
    func value() -> BlockHeight? {
        birthday
    }
}

// MARK: - Redactable String

/// Redactable holder for a string.
struct RedactableString: Equatable, Hashable, Redactable {
    let data: String
    
    init(_ data: String = "") { self.data = data }
}

/// Utility that converts a string to a redacted counterpart.
extension String {
    var redacted: RedactableString { RedactableString(self) }
}

// MARK: - Redactable BlockHeight

/// Redactable holder for a block height.
struct RedactableBlockHeight: Equatable, Redactable {
    let data: BlockHeight

    init(_ data: BlockHeight = -1) { self.data = data }
}

/// Utility that converts a block height to a redacted counterpart.
extension BlockHeight {
    var redacted: RedactableBlockHeight { RedactableBlockHeight(self) }
}

// MARK: - Redactable WalletBalance

/// Redactable holder for a wallet balance.
struct Balance: Equatable, Redactable {
    let data: WalletBalance

    init(_ data: WalletBalance = .zero) { self.data = data }
}

/// Utility that converts a string to a redacted counterpart.
extension WalletBalance {
    var redacted: Balance { Balance(self) }
}

extension Balance {
    static var zero: Balance {
        Self(WalletBalance(verified: .zero, total: .zero))
    }
}

// MARK: - Redactable Int64

/// Redactable holder for an Int64.
struct RedactableInt64: Equatable, Redactable {
    let data: Int64

    init(_ data: Int64 = -1) { self.data = data }
}

/// Utility that converts a block height to a redacted counterpart.
extension Int64 {
    var redacted: RedactableInt64 { RedactableInt64(self) }
}
