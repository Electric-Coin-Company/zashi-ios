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
        freeSpaceRequiredForSync: XCTUnimplemented("\(Self.self).freeSpaceRequiredForSync", placeholder: 0),
        hasEnoughFreeSpaceForSync: XCTUnimplemented("\(Self.self).hasEnoughFreeSpaceForSync", placeholder: false),
        freeSpace: XCTUnimplemented("\(Self.self).freeSpace", placeholder: 0)
    )
}
