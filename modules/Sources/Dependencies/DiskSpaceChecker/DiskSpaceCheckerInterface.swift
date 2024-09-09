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

@DependencyClient
public struct DiskSpaceCheckerClient {
    public var freeSpaceRequiredForSync: () -> Int64 = { 0 }
    public var hasEnoughFreeSpaceForSync: () -> Bool = { false }
    public var freeSpace: () -> Int64 = { 0 }
}
