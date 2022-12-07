import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

typealias WalletEventsFlowStore = Store<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>
typealias WalletEventsFlowViewStore = ViewStore<WalletEventsFlowReducer.State, WalletEventsFlowReducer.Action>

struct WalletEventsFlowReducer: ReducerProtocol {
    private enum CancelId {}

    struct State: Equatable {
        enum Destination: Equatable {
            case latest
            case all
            case showWalletEvent(WalletEvent)
        }

        var destination: Destination?

        @BindableState var alert: AlertState<WalletEventsFlowReducer.Action>?
        var latestMinedHeight: BlockHeight?
        var isScrollable = false
        var requiredTransactionConfirmations = 0
        var walletEvents = IdentifiedArrayOf<WalletEvent>.placeholder
        var selectedWalletEvent: WalletEvent?
    }

    enum Action: Equatable {
        case copyToPastboard(String)
        case dismissAlert
        case onAppear
        case onDisappear
        case openBlockExplorer(URL?)
        case updateDestination(WalletEventsFlowReducer.State.Destination?)
        case replyTo(String)
        case synchronizerStateChanged(SDKSynchronizerState)
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
            return sdkSynchronizer.stateChanged
                .map(WalletEventsFlowReducer.Action.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId.self, cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId.self)

        case .synchronizerStateChanged(.synced):
            if let latestMinedHeight = sdkSynchronizer.synchronizer?.latestScannedHeight {
                state.latestMinedHeight = latestMinedHeight
            }
            return sdkSynchronizer.getAllTransactions()
                .receive(on: mainQueue)
                .map(WalletEventsFlowReducer.Action.updateWalletEvents)
                .eraseToEffect()
            
        case .synchronizerStateChanged:
            return .none
            
        case .updateWalletEvents(let walletEvents):
            let sortedWalletEvents = walletEvents
                .sorted(by: { lhs, rhs in
                    lhs.timestamp > rhs.timestamp
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

        case .dismissAlert:
            state.alert = nil
            return .none

        case .warnBeforeLeavingApp(let blockExplorerURL):
            state.alert = AlertState(
                title: TextState("You are exiting your wallet"),
                message: TextState("""
                While usually an acceptable risk, you will possibly exposing your behavior and interest in this transaction by going online. \
                OH NOES! What will you do?
                """),
                primaryButton: .cancel(
                    TextState("NEVERMIND"),
                    action: .send(.dismissAlert)
                ),
                secondaryButton: .default(
                    TextState("SEE TX ONLINE"),
                    action: .send(.openBlockExplorer(blockExplorerURL))
                )
            )
            return .none

        case .openBlockExplorer(let blockExplorerURL):
            state.alert = nil
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
                guard let walletEvent = walletEvent else {
                    return false
                }
                
                return $0.destination.map(/WalletEventsFlowReducer.State.Destination.showWalletEvent) == walletEvent
            },
            send: { isActive in
                guard let walletEvent = walletEvent else {
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
