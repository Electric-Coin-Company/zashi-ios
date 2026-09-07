//
//  SmartBannerSyncStalledTests.swift
//  zodlTests
//
//  MOB-1853 — once automatic stall recovery has given up for good this foreground (the
//  terminal-stall rebuild budget spent, a rebuild blocked by the `bgTask`/server-setup guard, or a
//  dispatched rebuild that never actually started a pass), `Root` notifies the SmartBanner via
//  `.syncStalledTerminally(Bool)` (`RootTransactions.swift`'s `markSyncStalledTerminally`/
//  `clearSyncStalledTerminally`), and this lane (`.priorityStalled`, rank 1.25 — directly below
//  `.priority2` sync error and above `.priorityMigration`) shows an honest "Sync has stalled"
//  banner with a Retry action instead of the SDK's own `.syncing` publishing forever with nothing
//  said about it. `RootTerminalStallRebuildTests.swift` covers the Root-side wiring that produces
//  the notification; this file covers only the banner lane itself.
//
//  Mirrors `SmartBannerResidualSlotTests.swift`/`SmartBannerShieldingOfferLifecycleTests.swift` for
//  driving `SmartBanner` via `TestStore` with `exhaustivity = .off`, `mainQueue = .immediate`, and
//  an isolated `InMemoryStorage()` per test (`SmartBanner.State` carries `@Shared(.inMemory(...))`
//  process-global storage).
//

import ComposableArchitecture
import Foundation
import Testing
@testable @preconcurrency import ZcashLightClientKit
@testable import zodl_internal

@Suite(.serialized) @MainActor struct SmartBannerSyncStalledTests {
    private static func syncState(_ status: SyncStatus) -> RedactableSynchronizerState {
        var state = SynchronizerState.zero
        state.syncStatus = status
        return state.redacted
    }

    private func makeStore(
        priorityContent: SmartBanner.State.PriorityContent? = nil,
        isSyncStalledTerminally: Bool = false
    ) -> TestStore<SmartBanner.State, SmartBanner.Action> {
        var state = SmartBanner.State()
        state.priorityContent = priorityContent
        state.isSyncStalledTerminally = isSyncStalledTerminally

        let store = TestStore(initialState: state) {
            SmartBanner()
        }
        store.exhaustivity = .off
        store.dependencies.mainQueue = .immediate
        store.dependencies.walletStorage = .noOp
        store.dependencies.sdkSynchronizer = .noOp
        return store
    }

    /// The lane seats over an ordinary syncing snapshot (rank 1.25 outranks priority4's rank 3.0,
    /// so the ladder's own `isSyncingHigherPriority` re-trigger can never displace it), and closes
    /// the moment Root reports the stall cleared.
    @Test func theStalledBannerShowsOverASyncingSnapshotAndClosesWhenCleared() async {
        await withDependencies {
            $0.defaultInMemoryStorage = InMemoryStorage()
        } operation: {
            let store = makeStore()

            await store.send(.syncStalledTerminally(true)) {
                $0.isSyncStalledTerminally = true
            }
            await store.receive(\.triggerPriority)
            await store.receive(\.openBannerRequest)

            #expect(store.state.priorityContent == .priorityStalled)

            // An ordinary syncing snapshot with no restore/resync status and blocks-remaining below
            // threshold never even asks for priority4 — but even if it did, rank 1.25 outranks
            // rank 3.0, so the stalled banner would still hold the slot.
            await store.send(.synchronizerStateChanged(Self.syncState(.syncing(0.1, false))))
            await store.finish()
            await store.skipReceivedActions(strict: false)

            #expect(store.state.priorityContent == .priorityStalled, "an ordinary syncing tick must not displace the stronger stalled banner")

            await store.send(.syncStalledTerminally(false)) {
                $0.isSyncStalledTerminally = false
            }
            await store.finish()
            await store.skipReceivedActions(strict: false)

            #expect(store.state.priorityContent == nil, "clearing the flag while the lane is seated must close the banner")
        }
    }

    /// `.retryStalledSyncTapped` is a pure delegate — `Root` is the one that reacts to it
    /// (re-entering the rebuild path and, once it clears the flag, sending
    /// `.syncStalledTerminally(false)` back down); this reducer's own handler changes nothing.
    @Test func retryTapIsForwardedToTheParent() async {
        await withDependencies {
            $0.defaultInMemoryStorage = InMemoryStorage()
        } operation: {
            let store = makeStore(priorityContent: .priorityStalled, isSyncStalledTerminally: true)

            await store.send(.retryStalledSyncTapped)
            await store.finish()

            #expect(store.state.priorityContent == .priorityStalled)
            #expect(store.state.isSyncStalledTerminally)
        }
    }
}
