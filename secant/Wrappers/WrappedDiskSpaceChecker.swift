//
//  WrappedDiskSpaceChecker.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import Foundation

struct WrappedDiskSpaceChecker {
    let freeSpaceRequiredForSync: () -> Int64
    let hasEnoughFreeSpaceForSync: () -> Bool
    let freeSpace: () -> Int64
}

extension WrappedDiskSpaceChecker {
    static let live: WrappedDiskSpaceChecker = {
        let diskSpaceChecker = DiskSpaceChecker()
        return WrappedDiskSpaceChecker(
            freeSpaceRequiredForSync: { diskSpaceChecker.freeSpaceRequiredForSync() },
            hasEnoughFreeSpaceForSync: { diskSpaceChecker.hasEnoughFreeSpaceForSync() },
            freeSpace: { diskSpaceChecker.freeSpace() }
        )
    }()

    static let mockEmptyDisk = WrappedDiskSpaceChecker(
        freeSpaceRequiredForSync: { 1024 },
        hasEnoughFreeSpaceForSync: { true },
        freeSpace: { 2048 }
    )

    static let mockFullDisk = WrappedDiskSpaceChecker(
        freeSpaceRequiredForSync: { 1024 },
        hasEnoughFreeSpaceForSync: { false },
        freeSpace: { 0 }
    )
}
