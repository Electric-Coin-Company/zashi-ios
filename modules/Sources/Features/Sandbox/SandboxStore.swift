import ComposableArchitecture
import SwiftUI
import WalletEventsFlow

public typealias SandboxStore = Store<SandboxReducer.State, SandboxReducer.Action>
public typealias SandboxViewStore = ViewStore<SandboxReducer.State, SandboxReducer.Action>

public struct SandboxReducer: ReducerProtocol {
    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case history
            case send
            case recoveryPhraseDisplay
            case scan
        }
        public var walletEventsState: WalletEventsFlowReducer.State
        public var destination: Destination?
    }

    public enum Action: Equatable {
        case updateDestination(SandboxReducer.State.Destination?)
        case walletEvents(WalletEventsFlowReducer.Action)
        case reset
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .updateDestination(destination):
            state.destination = destination
            return .none
            
        case let .walletEvents(walletEventsAction):
            return WalletEventsFlowReducer()
                .reduce(into: &state.walletEventsState, action: walletEventsAction)
                .map(SandboxReducer.Action.walletEvents)
            
        case .reset:
            return .none
        }
    }
}

// MARK: - Store

extension SandboxStore {
    func historyStore() -> WalletEventsFlowStore {
        self.scope(
            state: \.walletEventsState,
            action: SandboxReducer.Action.walletEvents
        )
    }
}

// MARK: - ViewStore

extension SandboxViewStore {
    func toggleSelectedTransaction() {
        let isAlreadySelected = (self.selectedTranactionID != nil)
        let walletEvent = self.walletEventsState.walletEvents[5]
        let newDestination = isAlreadySelected ? nil : WalletEventsFlowReducer.State.Destination.showWalletEvent(walletEvent)
        send(.walletEvents(.updateDestination(newDestination)))
    }

    var selectedTranactionID: String? {
        self.walletEventsState
            .destination
            .flatMap(/WalletEventsFlowReducer.State.Destination.showWalletEvent)
            .map(\.id)
    }

    func bindingForDestination(_ destination: SandboxReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}

// MARK: - PlaceHolders

extension SandboxReducer.State {
    public static var placeholder: Self {
        .init(
            walletEventsState: .placeHolder,
            destination: nil
        )
    }
}

extension SandboxStore {
    public static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxReducer.State(
                walletEventsState: .placeHolder,
                destination: nil
            ),
            reducer: SandboxReducer()
        )
    }
}
