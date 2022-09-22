import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

typealias WalletEventsFlowReducer = Reducer<WalletEventsFlowState, WalletEventsFlowAction, WalletEventsFlowEnvironment>
typealias WalletEventsFlowStore = Store<WalletEventsFlowState, WalletEventsFlowAction>
typealias WalletEventsFlowViewStore = ViewStore<WalletEventsFlowState, WalletEventsFlowAction>

// MARK: - State

struct WalletEventsFlowState: Equatable {
    enum Route: Equatable {
        case latest
        case all
        case showWalletEvent(WalletEvent)
    }

    var route: Route?

    @BindableState var alert: AlertState<WalletEventsFlowAction>?
    var latestMinedHeight: BlockHeight?
    var isScrollable = false
    var requiredTransactionConfirmations = 0
    var walletEvents = IdentifiedArrayOf<WalletEvent>.placeholder
    var selectedWalletEvent: WalletEvent?
}

// MARK: - Action

enum WalletEventsFlowAction: Equatable {
    case copyToPastboard(String)
    case dismissAlert
    case onAppear
    case onDisappear
    case openBlockExplorer(URL?)
    case updateRoute(WalletEventsFlowState.Route?)
    case replyTo(String)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case updateWalletEvents([WalletEvent])
    case warnBeforeLeavingApp(URL?)
}

// MARK: - Environment

struct WalletEventsFlowEnvironment {
    let pasteboard: WrappedPasteboard
    let scheduler: AnySchedulerOf<DispatchQueue>
    let SDKSynchronizer: WrappedSDKSynchronizer
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

// MARK: - Reducer

extension WalletEventsFlowReducer {
    private struct CancelId: Hashable {}
    
    static let `default` = WalletEventsFlowReducer { state, action, environment in
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = environment.zcashSDKEnvironment.requiredTransactionConfirmations
            return environment.SDKSynchronizer.stateChanged
                .map(WalletEventsFlowAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .synchronizerStateChanged(.synced):
            if let latestMinedHeight = environment.SDKSynchronizer.synchronizer?.latestScannedHeight {
                state.latestMinedHeight = latestMinedHeight
            }
            return environment.SDKSynchronizer.getAllTransactions()
                .receive(on: environment.scheduler)
                .map(WalletEventsFlowAction.updateWalletEvents)
                .eraseToEffect()
            
        case .synchronizerStateChanged(let synchronizerState):
            return .none
            
        case .updateWalletEvents(let walletEvents):
            let sortedWalletEvents = walletEvents
                .sorted(by: { lhs, rhs in
                    lhs.timestamp > rhs.timestamp
                })
            state.walletEvents = IdentifiedArrayOf(uniqueElements: sortedWalletEvents)
            return .none

        case .updateRoute(.showWalletEvent(let walletEvent)):
            state.selectedWalletEvent = walletEvent
            state.route = .showWalletEvent(walletEvent)
            return .none

        case .updateRoute(let route):
            state.route = route
            if route == nil {
                state.selectedWalletEvent = nil
            }
            return .none
            
        case .copyToPastboard(let value):
            environment.pasteboard.setString(value)
            return .none
            
        case .replyTo(let address):
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
    private typealias Route = WalletEventsFlowState.Route

    func bindingForSelectedWalletEvent(_ walletEvent: WalletEvent?) -> Binding<Bool> {
        self.binding(
            get: {
                guard let walletEvent = walletEvent else {
                    return false
                }
                
                return $0.route.map(/WalletEventsFlowState.Route.showWalletEvent) == walletEvent
            },
            send: { isActive in
                guard let walletEvent = walletEvent else {
                    return WalletEventsFlowAction.updateRoute(nil)
                }
                
                return WalletEventsFlowAction.updateRoute( isActive ? WalletEventsFlowState.Route.showWalletEvent(walletEvent) : nil)
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

extension WalletEventsFlowState {
    static var placeHolder: Self {
        .init(walletEvents: .placeholder)
    }

    static var emptyPlaceHolder: Self {
        .init(walletEvents: [])
    }
}

extension WalletEventsFlowStore {
    static var placeholder: Store<WalletEventsFlowState, WalletEventsFlowAction> {
        return Store(
            initialState: .placeHolder,
            reducer: .default,
            environment: WalletEventsFlowEnvironment(
                pasteboard: .live,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                zcashSDKEnvironment: .testnet
            )
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
