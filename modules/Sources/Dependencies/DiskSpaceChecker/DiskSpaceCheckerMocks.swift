//
//  DiskSpaceCheckerMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 10.11.2022.
//

extension DiskSpaceCheckerClient {
    public static let mockEmptyDisk = DiskSpaceCheckerClient(
        freeSpaceRequiredForSync: { 1024 },
        hasEnoughFreeSpaceForSync: { true },
        freeSpace: { 2048 }
    )

    public static let mockFullDisk = DiskSpaceCheckerClient(
        freeSpaceRequiredForSync: { 1024 },
        hasEnoughFreeSpaceForSync: { false },
        freeSpace: { 0 }
    )
}
