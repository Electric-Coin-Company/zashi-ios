//
//  DiskSpaceCheckerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 10.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    var diskSpaceChecker: DiskSpaceCheckerClient {
        get { self[DiskSpaceCheckerClient.self] }
        set { self[DiskSpaceCheckerClient.self] = newValue }
    }
}

struct DiskSpaceCheckerClient {
    var freeSpaceRequiredForSync: () -> Int64
    var hasEnoughFreeSpaceForSync: () -> Bool
    var freeSpace: () -> Int64
}
