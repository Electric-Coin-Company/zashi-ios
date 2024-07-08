//
//  DiskSpaceCheckerTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 10.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension DiskSpaceCheckerClient: TestDependencyKey {
    public static let testValue = Self(
        freeSpaceRequiredForSync: unimplemented("\(Self.self).freeSpaceRequiredForSync", placeholder: 0),
        hasEnoughFreeSpaceForSync: unimplemented("\(Self.self).hasEnoughFreeSpaceForSync", placeholder: false),
        freeSpace: unimplemented("\(Self.self).freeSpace", placeholder: 0)
    )
}
