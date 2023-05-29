import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils

typealias WalletEventsFlowStore = Store<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>
typealias WalletEventsFlowViewStore = ViewStore<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>

struct WalletEventsFlowReducer: ReducerProtocol {
    private enum CancelId { case timer }

    struct State: Equatable {
        enum Destination: Equatable {
            case latest
            case all
            case showWalletEvent(WalletEvent)
        }

        var destination: Destination?

        var latestMinedHeight: BlockHeight?
        var isScrollable = true
        var requiredTransactionConfirmations = 0
        var walletEvents = IdentifiedArrayOf<WalletEvent>.placeholder
        var selectedWalletEvent: WalletEvent?
    }

    enum Action: Equatable {
        case alert(AlertRequest)
        case copyToPastboard(RedactableString)
        case onAppear
        case onDisappear
        case openBlockExplorer(URL?)
        case updateDestination(WalletEventsFlowReducer.State.Destination?)
        case replyTo(RedactableString)
        case synchronizerStateChanged(SyncStatus)
        case updateWalletEvents([WalletEvent])
        case warnBeforeLeavingApp(URL?)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    // swiftlint:disable:next cyclomatic_complexity
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations
            return sdkSynchronizer.stateStream()
                .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                .map { WalletEventsFlowReducer.Action.synchronizerStateChanged($0.syncStatus) }
                .eraseToEffect()
                .cancellable(id: CancelId.timer, cancelInFlight: true)

        case .onDisappear:
            return .cancel(id: CancelId.timer)

        case .synchronizerStateChanged(.upToDate):
            state.latestMinedHeight = sdkSynchronizer.latestScannedHeight()
            return .task {
                return .updateWalletEvents(try await sdkSynchronizer.getAllTransactions())
            }
            
        case .synchronizerStateChanged:
            return .none
            
        case .updateWalletEvents(let walletEvents):
            let sortedWalletEvents = walletEvents
                .sorted(by: { lhs, rhs in
                    guard let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp else {
                        return false
                    }
                    return lhsTimestamp > rhsTimestamp
                })
            state.walletEvents = IdentifiedArrayOf(uniqueElements: sortedWalletEvents)
            return .none

        case .updateDestination(.showWalletEvent(let walletEvent)):
            state.selectedWalletEvent = walletEvent
            state.destination = .showWalletEvent(walletEvent)
            return .none

        case .updateDestination(let destination):
            state.destination = destination
            if destination == nil {
                state.selectedWalletEvent = nil
            }
            return .none
            
        case .copyToPastboard(let value):
            pasteboard.setString(value)
            return .none
            
        case .replyTo:
            return .none

        case .alert:
            return .none

        case .warnBeforeLeavingApp(let blockExplorerURL):
            return EffectTask(value: .alert(.walletEvents(.warnBeforeLeavingApp(blockExplorerURL))))

        case .openBlockExplorer(let blockExplorerURL):
            if let url = blockExplorerURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return .none
        }
    }
}

// MARK: - ViewStore

extension WalletEventsFlowViewStore {
    private typealias Destination = WalletEventsFlowReducer.State.Destination

    func bindingForSelectedWalletEvent(_ walletEvent: WalletEvent?) -> Binding<Bool> {
        self.binding(
            get: {
                guard let walletEvent else {
                    return false
                }
                
                return $0.destination.map(/WalletEventsFlowReducer.State.Destination.showWalletEvent) == walletEvent
            },
            send: { isActive in
                guard let walletEvent else {
                    return WalletEventsFlowReducer.Action.updateDestination(nil)
                }
                
                return WalletEventsFlowReducer.Action.updateDestination(
                    isActive ? WalletEventsFlowReducer.State.Destination.showWalletEvent(walletEvent) : nil
                )
            }
        )
    }
}

// MARK: Placeholders

extension TransactionState {
    static var placeholder: Self {
        .init(
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(10),
            id: "2",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(123_000_000)
        )
    }
    
    static func statePlaceholder(_ status: Status) -> Self {
        .init(
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(10),
            id: "2",
            status: status,
            timestamp: 1234567,
            zecAmount: Zatoshi(123_000_000)
        )
    }
}

extension WalletEventsFlowReducer.State {
    static var placeHolder: Self {
        .init(walletEvents: .placeholder)
    }

    static var emptyPlaceHolder: Self {
        .init(walletEvents: [])
    }
}

extension WalletEventsFlowStore {
    static var placeholder: Store<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action> {
        return Store(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
                .dependency(\.zcashSDKEnvironment, .testnet)
        )
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    static var placeholder: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(10),
                    id: String($0),
                    status: .paid(success: true),
                    timestamp: 1234567,
                    zecAmount: Zatoshi(25)
                )
            }
        )
    }
}
