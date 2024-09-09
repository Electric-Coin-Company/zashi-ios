//
//  AutolockHandlerInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-10-2024.
//

import ComposableArchitecture
import UIKit

extension DependencyValues {
    public var autolockHandler: AutolockHandlerClient {
        get { self[AutolockHandlerClient.self] }
        set { self[AutolockHandlerClient.self] = newValue }
    }
}

@DependencyClient
public struct AutolockHandlerClient {
    public var value: (Bool) -> Void
    public var batteryStatePublisher: () -> NotificationCenter.Publisher = { .init(center: .default, name: .AVAssetChapterMetadataGroupsDidChange) }
}
