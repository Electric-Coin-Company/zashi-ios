//
//  LocalNotificationInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 04-07-2025.
//

import ComposableArchitecture

extension DependencyValues {
    public var localNotification: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}

@DependencyClient
public struct LocalNotificationClient {
    public enum Constants {
        public static let walletBackupUUID = "com.zashi.wallet-backup-local-notification"
        public static let shieldingUUID = "com.zashi.shielding-local-notification"
    }

    public let clearNotifications: () -> Void
    public let isShieldingScheduled: () async -> Bool
    public let isWalletBackupScheduled: () async -> Bool
    public let scheduleShielding: () -> Void
    public let scheduleWalletBackup: () -> Void
}
