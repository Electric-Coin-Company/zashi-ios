//
//  LocalNotificationLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 04-07-2025.
//

import Foundation
import UserNotifications
import ComposableArchitecture
import Generated

extension LocalNotificationClient: DependencyKey {
    public static let liveValue: LocalNotificationClient = Self.live()
    
    public static func live() -> Self {
        return LocalNotificationClient(
            clearNotifications: {
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: [
                        Constants.walletBackupUUID,
                        Constants.shieldingUUID
                    ]
                )
            },
            isShieldingScheduled: {
                await withCheckedContinuation { continuation in
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        let res = requests.contains { $0.identifier == Constants.shieldingUUID }
                        continuation.resume(returning: res)
                    }
                }
            },
            isWalletBackupScheduled: {
                await withCheckedContinuation { continuation in
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        let res = requests.contains { $0.identifier == Constants.walletBackupUUID }
                        continuation.resume(returning: res)
                    }
                }
            },
            scheduleShielding: {
                guard let futureDate = Calendar.current.date(byAdding: .hour, value: 48, to: Date()) else {
                    return
                }
              
                scheduleNotification(
                    title: L10n.SmartBanner.Content.Shield.title,
                    body: "",
                    date: futureDate,
                    identifier: Constants.shieldingUUID
                )
            },
            scheduleWalletBackup: {
                guard let futureDate = Calendar.current.date(byAdding: .hour, value: 48, to: Date()) else {
                    return
                }

                scheduleNotification(
                    title: L10n.SmartBanner.Content.Backup.title,
                    body: L10n.SmartBanner.Content.Backup.info,
                    date: futureDate,
                    identifier: Constants.walletBackupUUID
                )
            }
        )
    }
}

private extension LocalNotificationClient {
    static func scheduleNotification(
        title: String,
        body: String,
        date: Date,
        identifier: String
    ) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                return
            }
        }

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["customData": "fizzbuzz"]

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request)
    }
}
