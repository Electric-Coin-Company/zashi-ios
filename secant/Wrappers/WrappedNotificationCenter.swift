//
//  WrappedNotificationCenter.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.05.2022.
//

import Foundation

struct WrappedNotificationCenter {
    let publisherFor: (Notification.Name) -> NotificationCenter.Publisher?
}

extension WrappedNotificationCenter {
    static let live = WrappedNotificationCenter(
        publisherFor: { NotificationCenter.default.publisher(for: $0) }
    )
    
    static let mock = WrappedNotificationCenter(
        publisherFor: { _ in nil }
    )
}
