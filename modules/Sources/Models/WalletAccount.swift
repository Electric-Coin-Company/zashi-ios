//
//  WalletAccount.swift
//  modules
//
//  Created by Lukáš Korba on 26.11.2024.
//

import SwiftUI

import Generated

public struct WalletAccount: Equatable, Hashable, Codable, Identifiable {
    public enum Vendor: Equatable, Codable, Hashable {
        case keystone
        case zcash
        
        public func icon() -> Image {
            switch self {
            case .keystone:
                return Asset.Assets.Partners.keystoneLogoLight.image
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
                return "Keystone"
            case .zcash:
                return "Zashi"
            }
        }
    }
    
    public static let `default` = WalletAccount(
        id: "0",
        vendor: .zcash
    )

    public let id: String
    public let vendor: Vendor
    
    public init(
        id: String,
        vendor: Vendor
    ) {
        self.id = id
        self.vendor = vendor
    }
}
