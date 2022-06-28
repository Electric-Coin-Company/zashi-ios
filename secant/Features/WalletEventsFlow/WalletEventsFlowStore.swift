import ComposableArchitecture
import SwiftUI

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

    var isScrollable = false
    var walletEvents = IdentifiedArrayOf<WalletEvent>.placeholder
}

// MARK: - Action

enum WalletEventsFlowAction: Equatable {
    case copyToPastboard(String)
    case onAppear
    case onDisappear
    case updateRoute(WalletEventsFlowState.Route?)
    case replyTo(String)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case updateWalletEvents([WalletEvent])
}

// MARK: - Environment

struct WalletEventsFlowEnvironment {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let SDKSynchronizer: WrappedSDKSynchronizer
    let pasteboard: WrappedPasteboard
}

// MARK: - Reducer

extension WalletEventsFlowReducer {
    private struct CancelId: Hashable {}
    
    static let `default` = WalletEventsFlowReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.SDKSynchronizer.stateChanged
                .map(WalletEventsFlowAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .synchronizerStateChanged(.synced):
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

        case .updateRoute(let route):
            state.route = route
            return .none
            
        case .copyToPastboard(let value):
            environment.pasteboard.setString(value)
            return .none
            
        case .replyTo(let address):
            return .none
        }
    }
}

// MARK: - ViewStore

extension WalletEventsFlowViewStore {
    private typealias Route = WalletEventsFlowState.Route

    func bindingForSelectingWalletEvent(_ walletEvent: WalletEvent) -> Binding<Bool> {
        self.binding(
            get: { $0.route.map(/WalletEventsFlowState.Route.showWalletEvent) == walletEvent },
            send: { isActive in
                WalletEventsFlowAction.updateRoute( isActive ? WalletEventsFlowState.Route.showWalletEvent(walletEvent) : nil)
            }
        )
    }
}

// MARK: Placeholders

extension TransactionState {
    static var placeholder: Self {
        .init(
            fee: Zatoshi(amount: 10),
            id: "2",
            status: .paid(success: true),
            subtitle: "",
            timestamp: 1234567,
            zecAmount: Zatoshi(amount: 25)
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
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                pasteboard: .live
            )
        )
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    static var placeholder: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(amount: 10),
                    id: String($0),
                    status: .paid(success: true),
                    subtitle: "",
                    timestamp: 1234567,
                    zecAmount: Zatoshi(amount: 25)
                )
            }
        )
    }
}
