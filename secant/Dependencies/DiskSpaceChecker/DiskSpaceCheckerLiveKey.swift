//
//  DiskSpaceCheckerLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 10.11.2022.
//

import ComposableArchitecture

extension DiskSpaceCheckerClient: DependencyKey {
    static let liveValue: Self = {
        let diskSpaceChecker = DiskSpaceChecker()
        return Self(
            freeSpaceRequiredForSync: { diskSpaceChecker.freeSpaceRequiredForSync() },
            hasEnoughFreeSpaceForSync: { diskSpaceChecker.hasEnoughFreeSpaceForSync() },
            freeSpace: { diskSpaceChecker.freeSpace() }
        )
    }()
}
