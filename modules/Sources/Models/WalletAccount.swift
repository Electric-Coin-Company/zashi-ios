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
    public enum Vendor: Equatable, Codable, Hashable {
        case keystone
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
                return "Keystone"
            case .zcash:
                return "Zashi"
            }
        }
    }
    
    public static let `default` = WalletAccount(
        id: 0,
        vendor: .zcash,
        uaAddressString: "u1078r23uvtj8xj6dpdx..."
    )

    // TODO: this will be UUID once supported in the SDK
    public let id: UInt32
    public let vendor: Vendor
    public var uaAddressString: String

    public init(
        id: UInt32,
        vendor: Vendor,
        uaAddressString: String = ""
    ) {
        self.id = id
        self.vendor = vendor
        self.uaAddressString = uaAddressString
    }
}
