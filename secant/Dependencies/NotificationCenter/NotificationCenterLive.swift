//
//  NotificationCenterLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation

extension NotificationCenterClient {
    static let live = NotificationCenterClient(
        publisherFor: { NotificationCenter.default.publisher(for: $0) }
    )
}
