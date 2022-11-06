import ComposableArchitecture
import SwiftUI

typealias SandboxStore = Store<SandboxReducer.State, SandboxReducer.Action>
typealias SandboxViewStore = ViewStore<SandboxReducer.State, SandboxReducer.Action>

struct SandboxReducer: ReducerProtocol {
    struct State: Equatable {
        enum Route: Equatable, CaseIterable {
            case history
            case send
            case recoveryPhraseDisplay
            case profile
            case scan
            case request
        }
        var walletEventsState: WalletEventsFlowReducer.State
        var profileState: ProfileState
        var route: Route?
    }

    enum Action: Equatable {
        case updateRoute(SandboxReducer.State.Route?)
        case walletEvents(WalletEventsFlowReducer.Action)
        case profile(ProfileAction)
        case reset
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
            
        case let .walletEvents(walletEventsAction):
            return WalletEventsFlowReducer()
                .reduce(into: &state.walletEventsState, action: walletEventsAction)
                .map(SandboxReducer.Action.walletEvents)

        case .profile:
            return ProfileReducer
                .default
                .pullback(
                    state: \.profileState,
                    action: /SandboxReducer.Action.profile,
                    environment: { _ in ProfileEnvironment.live }
                )
                .run(&state, action, ())
            
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
        let newRoute = isAlreadySelected ? nil : WalletEventsFlowReducer.State.Route.showWalletEvent(walletEvent)
        send(.walletEvents(.updateRoute(newRoute)))
    }

    var selectedTranactionID: String? {
        self.walletEventsState
            .route
            .flatMap(/WalletEventsFlowReducer.State.Route.showWalletEvent)
            .map(\.id)
    }

    func bindingForRoute(_ route: SandboxReducer.State.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
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
            route: nil
        )
    }
}

extension SandboxStore {
    static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxReducer.State(
                walletEventsState: .placeHolder,
                profileState: .placeholder,
                route: nil
            ),
            reducer: SandboxReducer()
        )
    }
}
