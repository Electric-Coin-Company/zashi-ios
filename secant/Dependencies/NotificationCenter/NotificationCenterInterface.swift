//
//  NotificationCenter.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.05.2022.
//

import Foundation

struct NotificationCenterClient {
    let publisherFor: (Notification.Name) -> NotificationCenter.Publisher?
}
