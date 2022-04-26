import ComposableArchitecture
import SwiftUI

struct SandboxState: Equatable {
    enum Route: Equatable, CaseIterable {
        case history
        case send
        case recoveryPhraseDisplay
        case profile
        case scan
        case request
    }
    var transactionHistoryState: TransactionHistoryState
    var profileState: ProfileState
    var route: Route?
}

enum SandboxAction: Equatable {
    case updateRoute(SandboxState.Route?)
    case transactionHistory(TransactionHistoryAction)
    case profile(ProfileAction)
    case reset
}

// MARK: - SandboxReducer

typealias SandboxReducer = Reducer<SandboxState, SandboxAction, Void>

extension SandboxReducer {
    static let `default` = SandboxReducer { state, action, environment in
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
        case let .transactionHistory(transactionHistoryAction):
            return TransactionHistoryReducer
                .default
                .run(
                    &state.transactionHistoryState,
                    transactionHistoryAction,
                    TransactionHistoryEnvironment(
                        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                        wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
                    )
                )
                .map(SandboxAction.transactionHistory)
        case let .profile(profileAction):
            return ProfileReducer
                .default
                .pullback(
                    state: \.profileState,
                    action: /SandboxAction.profile,
                    environment: { _ in
                        return ProfileEnvironment()
                    }
                )
                .run(&state, action, ())
        case .reset:
            return .none
        }
    }
}

// MARK: - SandboxStore

typealias SandboxStore = Store<SandboxState, SandboxAction>

extension SandboxStore {
    func historyStore() -> TransactionHistoryStore {
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

// MARK: - SandboxViewStore

typealias SandboxViewStore = ViewStore<SandboxState, SandboxAction>

extension SandboxViewStore {
    func toggleSelectedTransaction() {
        let isAlreadySelected = (self.selectedTranactionID != nil)
        let transcation = self.transactionHistoryState.transactions[5]
        let newRoute = isAlreadySelected ? nil : TransactionHistoryState.Route.showTransaction(transcation)
        send(.transactionHistory(.updateRoute(newRoute)))
    }

    var selectedTranactionID: String? {
        self.transactionHistoryState
            .route
            .flatMap(/TransactionHistoryState.Route.showTransaction)
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

// MARK: PlaceHolders
extension SandboxState {
    static var placeholder: Self {
        .init(
            transactionHistoryState: .placeHolder,
            profileState: .placeholder,
            route: nil
        )
    }
}
