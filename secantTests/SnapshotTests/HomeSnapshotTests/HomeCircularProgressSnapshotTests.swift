//
//  HomeCircularProgressSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 07.07.2022.
//

import XCTest
import ComposableArchitecture
@testable import secant_testnet
@testable import ZcashLightClientKit

class HomeCircularProgressSnapshotTests: XCTestCase {
    func testCircularProgress_DownloadingInnerCircle() throws {
        class SnapshotNoopSDKSynchronizer: NoopSDKSynchronizer {
            // heights purposely set so we visually see 55% progress
            override func statusSnapshot() -> SyncStatusSnapshot {
                let blockProgress = BlockProgress(
                    startHeight: BlockHeight(0),
                    targetHeight: BlockHeight(100),
                    progressHeight: BlockHeight(55)
                )
                
                return SyncStatusSnapshot.snapshotFor(state: .downloading(blockProgress))
            }
        }

        let balance = WalletBalance(verified: Zatoshi(15_345_000), total: Zatoshi(15_345_000))

        let store = HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
                .dependency(\.sdkSynchronizer, SnapshotNoopSDKSynchronizer())
        )

        addAttachments(HomeView(store: store))
    }
    
    func testCircularProgress_ScanningOuterCircle() throws {
        class SnapshotNoopSDKSynchronizer: NoopSDKSynchronizer {
            override func statusSnapshot() -> SyncStatusSnapshot {
                // heights purposely set so we visually see 72% progress
                let blockProgress = BlockProgress(
                    startHeight: BlockHeight(0),
                    targetHeight: BlockHeight(100),
                    progressHeight: BlockHeight(72)
                )
                
                return SyncStatusSnapshot.snapshotFor(state: .scanning(blockProgress))
            }
        }

        let balance = WalletBalance(verified: 15_345_000, total: 15_345_000)

        let store = HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
        )

        addAttachments(HomeView(store: store))
    }
    
    func testCircularProgress_UpToDateOnlyOuterCircle() throws {
        class SnapshotNoopSDKSynchronizer: NoopSDKSynchronizer {
            override func statusSnapshot() -> SyncStatusSnapshot {
                SyncStatusSnapshot.snapshotFor(state: .synced)
            }
        }

        let balance = WalletBalance(verified: 15_345_000, total: 15_345_000)

        let store = HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
        )

        addAttachments(HomeView(store: store))
    }
}
