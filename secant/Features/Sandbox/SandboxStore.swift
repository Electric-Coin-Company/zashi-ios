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
    var transactionHistoryState: TransactionHistoryFlowState
    var profileState: ProfileState
    var route: Route?
}

// MARK: - Action

enum SandboxAction: Equatable {
    case updateRoute(SandboxState.Route?)
    case transactionHistory(TransactionHistoryFlowAction)
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
        case let .transactionHistory(transactionHistoryAction):
            return TransactionHistoryFlowReducer
                .default
                .run(
                    &state.transactionHistoryState,
                    transactionHistoryAction,
                    TransactionHistoryFlowEnvironment(
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        SDKSynchronizer: LiveWrappedSDKSynchronizer()
                    )
                )
                .map(SandboxAction.transactionHistory)
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
    func historyStore() -> TransactionHistoryFlowStore {
        self.scope(
            state: \.transactionHistoryState,
            action: SandboxAction.transactionHistory
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
        let transcation = self.transactionHistoryState.transactions[5]
        let newRoute = isAlreadySelected ? nil : TransactionHistoryFlowState.Route.showTransaction(transcation)
        send(.transactionHistory(.updateRoute(newRoute)))
    }

    var selectedTranactionID: String? {
        self.transactionHistoryState
            .route
            .flatMap(/TransactionHistoryFlowState.Route.showTransaction)
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
            transactionHistoryState: .placeHolder,
            profileState: .placeholder,
            route: nil
        )
    }
}

extension SandboxStore {
    static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxState(
                transactionHistoryState: .placeHolder,
                profileState: .placeholder,
                route: nil
            ),
            reducer: .default.debug(),
            environment: SandboxEnvironment()
        )
    }
}
