import ComposableArchitecture
import SwiftUI
import Profile

typealias SandboxStore = Store<SandboxReducer.State, SandboxReducer.Action>
typealias SandboxViewStore = ViewStore<SandboxReducer.State, SandboxReducer.Action>

struct SandboxReducer: ReducerProtocol {
    struct State: Equatable {
        enum Destination: Equatable, CaseIterable {
            case history
            case send
            case recoveryPhraseDisplay
            case profile
            case scan
        }
        var walletEventsState: WalletEventsFlowReducer.State
        var profileState: ProfileReducer.State
        var destination: Destination?
    }

    enum Action: Equatable {
        case updateDestination(SandboxReducer.State.Destination?)
        case walletEvents(WalletEventsFlowReducer.Action)
        case profile(ProfileReducer.Action)
        case reset
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .updateDestination(destination):
            state.destination = destination
            return .none
            
        case let .walletEvents(walletEventsAction):
            return WalletEventsFlowReducer()
                .reduce(into: &state.walletEventsState, action: walletEventsAction)
                .map(SandboxReducer.Action.walletEvents)

        case .profile:
            return Scope(state: \SandboxReducer.State.profileState, action: /SandboxReducer.Action.profile) {
                ProfileReducer()
            }
            .reduce(into: &state, action: action)
            
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

    func profileStore() -> ProfileStore {
        self.scope(
            state: \.profileState,
            action: SandboxReducer.Action.profile
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
    static var placeholder: Self {
        .init(
            walletEventsState: .placeHolder,
            profileState: .placeholder,
            destination: nil
        )
    }
}

extension SandboxStore {
    static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxReducer.State(
                walletEventsState: .placeHolder,
                profileState: .placeholder,
                destination: nil
            ),
            reducer: SandboxReducer()
        )
    }
}
