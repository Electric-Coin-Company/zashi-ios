import ComposableArchitecture
import SwiftUI

typealias SandboxReducer = Reducer<SandboxState, SandboxAction, SandboxEnvironment>
typealias SandboxStore = Store<SandboxState, SandboxAction>
typealias SandboxViewStore = ViewStore<SandboxState, SandboxAction>

// MARK: - State

struct SandboxState: Equatable {
    enum Route: Equatable, CaseIterable {
        case history
        case send
        case recoveryPhraseDisplay
        case profile
        case scan
        case request
    }
    var walletEventsState: WalletEventsFlowState
    var profileState: ProfileState
    var route: Route?
}

// MARK: - Action

enum SandboxAction: Equatable {
    case updateRoute(SandboxState.Route?)
    case walletEvents(WalletEventsFlowAction)
    case profile(ProfileAction)
    case reset
}

// MARK: - Environment

struct SandboxEnvironment { }

// MARK: - Reducer

extension SandboxReducer {
    static let `default` = SandboxReducer { state, action, environment in
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
        case let .walletEvents(walletEventsAction):
            return WalletEventsFlowReducer
                .default
                .run(
                    &state.walletEventsState,
                    walletEventsAction,
                    WalletEventsFlowEnvironment(
                        pasteboard: .live,
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                        zcashSDKEnvironment: .testnet
                    )
                )
                .map(SandboxAction.walletEvents)
        case let .profile(profileAction):
            return ProfileReducer
                .default
                .pullback(
                    state: \.profileState,
                    action: /SandboxAction.profile,
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
            action: SandboxAction.walletEvents
        )
    }

    func profileStore() -> ProfileStore {
        self.scope(
            state: \.profileState,
            action: SandboxAction.profile
        )
    }
}

// MARK: - ViewStore

extension SandboxViewStore {
    func toggleSelectedTransaction() {
        let isAlreadySelected = (self.selectedTranactionID != nil)
        let walletEvent = self.walletEventsState.walletEvents[5]
        let newRoute = isAlreadySelected ? nil : WalletEventsFlowState.Route.showWalletEvent(walletEvent)
        send(.walletEvents(.updateRoute(newRoute)))
    }

    var selectedTranactionID: String? {
        self.walletEventsState
            .route
            .flatMap(/WalletEventsFlowState.Route.showWalletEvent)
            .map(\.id)
    }

    func bindingForRoute(_ route: SandboxState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

// MARK: - PlaceHolders

extension SandboxState {
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
            initialState: SandboxState(
                walletEventsState: .placeHolder,
                profileState: .placeholder,
                route: nil
            ),
            reducer: .default,
            environment: SandboxEnvironment()
        )
    }
}
