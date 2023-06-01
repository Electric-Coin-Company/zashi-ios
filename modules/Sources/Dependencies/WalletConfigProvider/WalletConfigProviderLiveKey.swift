//
//  WalletConfigProviderLiveKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation

extension WalletConfigProviderClient: DependencyKey {
    public static let liveValue = WalletConfigProviderClient.live()

    public static var defaultWalletConfigProvider: WalletConfigProvider {
        WalletConfigProvider(
            configSourceProvider: UserDefaultsWalletConfigProvider(),
            cache: UserDefaultsWalletConfigProviderCache()
        )
    }

    public static func live(walletConfigProvider: WalletConfigProvider = WalletConfigProviderClient.defaultWalletConfigProvider) -> Self {
        Self(
            load: { walletConfigProvider.load() },
            update: { flag, isEnabled in
                return walletConfigProvider.update(featureFlag: flag, isEnabled: isEnabled)
            }
        )
    }
}
