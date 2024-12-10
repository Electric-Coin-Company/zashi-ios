//
//  WalletAccount.swift
//  modules
//
//  Created by Lukáš Korba on 26.11.2024.
//

import SwiftUI
import ZcashLightClientKit

import Generated

public struct WalletAccount: Equatable, Hashable, Codable, Identifiable {
    public enum Vendor: Int, Equatable, Codable, Hashable {
        case keystone = 0
        case zcash
        
        public func icon() -> Image {
            switch self {
            case .keystone:
                return Asset.Assets.Partners.keystoneLogo.image
            case .zcash:
                return Asset.Assets.Icons.zashiLogoSq.image
            }
        }

        public func isDefault() -> Bool {
            self == .zcash
        }
        
        public func isHWWallet() -> Bool {
            self != .zcash
        }
        
        public func name() -> String {
            switch self {
            case .keystone:
                return L10n.Accounts.keystone
            case .zcash:
                return L10n.Accounts.zashi
            }
        }
    }

    public let id: AccountUUID
    public let vendor: Vendor
    public var uAddress: UnifiedAddress?
    public var seedFingerprint: [UInt8]?
    public var zip32AccountIndex: Zip32AccountIndex?

    public var unifiedAddress: String? {
        uAddress?.stringEncoded
    }

    public var transparentAddress: String? {
        try? uAddress?.transparentReceiver().stringEncoded
    }

    public init(_ account: Account) {
        self.id = account.id
        self.vendor = account.keySource == L10n.Accounts.keystone.lowercased() ? .keystone : .zcash
        self.seedFingerprint = account.seedFingerprint
        self.zip32AccountIndex = account.hdAccountIndex
    }
}
