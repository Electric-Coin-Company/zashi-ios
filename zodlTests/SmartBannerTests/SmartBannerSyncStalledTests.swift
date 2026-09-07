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
    private static func syncState(
        _ status: SyncStatus,
        latestBlockHeight: BlockHeight = .zero
    ) -> RedactableSynchronizerState {
        var state = SynchronizerState.zero
        state.syncStatus = status
        state.latestBlockHeight = latestBlockHeight
        return state.redacted
    }

    private func makeStore(
        priorityContent: SmartBanner.State.PriorityContent? = nil,
        isSyncStalledTerminally: Bool = false,
        lastKnownErrorMessage: String = ""
    ) -> TestStore<SmartBanner.State, SmartBanner.Action> {
        var state = SmartBanner.State()
        state.priorityContent = priorityContent
        state.isSyncStalledTerminally = isSyncStalledTerminally
        state.lastKnownErrorMessage = lastKnownErrorMessage

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

            // Seeded WELL above `Constants.smartBannerSyncingBlocksThreshold` (3456) so priority4's
            // own re-trigger genuinely fires and competes for the slot — a snapshot left at
            // `SynchronizerState.zero`'s default (0 remaining blocks) would never even ask, which
            // would make the assertion below vacuous. `priorityContentRequested` landing on
            // `.priority4` is the proof the request was actually made; `priorityContent` staying on
            // `.priorityStalled` is the proof rank 1.25 still beat rank 3.0 and the request lost.
            await store.send(.synchronizerStateChanged(Self.syncState(.syncing(0.1, false), latestBlockHeight: 4_200_000)))
            await store.finish()
            await store.skipReceivedActions(strict: false)

            #expect(store.state.priorityContentRequested == .priority4, "the syncing snapshot must genuinely ask for priority4, not silently skip because blocks-remaining stayed under threshold")
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

    /// MOB-1853 review fix: `priority2` (sync error, rank 1) outranks `priorityStalled` (rank
    /// 1.25) and displaces it while the error is showing — but the stall itself can still be
    /// genuinely terminal underneath (Root's own flag is untouched by a sync error clearing), so
    /// once the error clears, the ladder must re-walk through `.evaluatePriorityStalled` rather
    /// than just closing and stopping, or a still-stalled wallet is left as a bare, unexplained
    /// spinner.
    @Test func aTransientSyncErrorReRaisesTheStalledBannerOnceItClears() async {
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

            // A sync error outranks the stalled lane (rank 1 vs 1.25) and displaces it.
            await store.send(.synchronizerStateChanged(Self.syncState(.error(ZcashError.compactBlockProcessorCritical))))
            await store.finish()
            await store.skipReceivedActions(strict: false)
            #expect(store.state.priorityContent == .priority2)
            #expect(store.state.isSyncStalledTerminally, "Root never cleared the flag -- the stall itself is still terminal underneath the transient error")

            // The error clears, but the wallet is still stuck -- the stalled banner must come back
            // rather than leaving a bare spinner behind.
            await store.send(.synchronizerStateChanged(Self.syncState(.syncing(0.1, false))))
            await store.finish()
            await store.skipReceivedActions(strict: false)
            #expect(store.state.priorityContent == .priorityStalled, "clearing a transient error must re-raise the still-terminal stalled banner, not leave the banner closed")
        }
    }

    /// The negative of the test above: if Root's flag clears WHILE the transient error is showing
    /// (the rebuild that caused the error dispatched in the meantime actually started a pass), the
    /// re-walk triggered once the error itself clears must continue past `.priorityStalled` rather
    /// than reseat it — `.evaluatePriorityStalled`'s own guard on `state.isSyncStalledTerminally`
    /// is what makes that call, same as every other entry into that rung.
    @Test func theLadderContinuesPastStalledWhenTheFlagClearedWhileAnErrorWasShowing() async {
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

            await store.send(.synchronizerStateChanged(Self.syncState(.error(ZcashError.compactBlockProcessorCritical))))
            await store.finish()
            await store.skipReceivedActions(strict: false)
            #expect(store.state.priorityContent == .priority2)

            // The flag clears while the error banner is still up -- `.priorityContent` is
            // `.priority2`, not `.priorityStalled`, so this only retracts THIS lane's own seat
            // (there isn't one to retract) and leaves the error banner exactly where it was.
            await store.send(.syncStalledTerminally(false)) {
                $0.isSyncStalledTerminally = false
            }
            await store.finish()
            #expect(store.state.priorityContent == .priority2, "clearing the flag must not touch a DIFFERENT lane's seat")

            // The error clears -- the ladder re-walks through `.evaluatePriorityStalled`, finds the
            // flag false, and must continue past it rather than reseating a stall that is over.
            await store.send(.synchronizerStateChanged(Self.syncState(.syncing(0.1, false))))
            await store.finish()
            await store.skipReceivedActions(strict: false)
            #expect(store.state.priorityContent != .priorityStalled, "the ladder must continue past stalled once the flag is no longer set")
        }
    }

    /// MOB-1853 review fix: `isSyncTimedOut` latches on `lastKnownErrorMessage`, which is never
    /// cleared for the session — checking it before the priority-specific sheets would send a
    /// wallet that saw a 504 earlier and has since stalled to the stale timed-out sheet instead of
    /// the stalled help it actually needs.
    @Test func tappingTheStalledBannerOpensTheStalledHelpEvenAfterAnEarlierTimeout() async {
        await withDependencies {
            $0.defaultInMemoryStorage = InMemoryStorage()
        } operation: {
            let store = makeStore(
                priorityContent: .priorityStalled,
                isSyncStalledTerminally: true,
                lastKnownErrorMessage: "504 gateway timeout"
            )
            #expect(store.state.isSyncTimedOut, "the fixture must actually exercise the timed-out latch this is testing against")

            await store.send(.smartBannerContentTapped)

            #expect(store.state.isSmartBannerSheetPresented, "must open the generic, priority-driven sheet so `.priorityStalled` routes to the stalled help content")
            #expect(store.state.isSyncTimedOutSheetPresented == false, "must NOT fall into the stale timed-out sheet")
        }
    }
}
