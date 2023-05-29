//
//  DiskSpaceCheckerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 10.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    public var diskSpaceChecker: DiskSpaceCheckerClient {
        get { self[DiskSpaceCheckerClient.self] }
        set { self[DiskSpaceCheckerClient.self] = newValue }
    }
}

public struct DiskSpaceCheckerClient {
    public var freeSpaceRequiredForSync: () -> Int64
    public var hasEnoughFreeSpaceForSync: () -> Bool
    public var freeSpace: () -> Int64
}
