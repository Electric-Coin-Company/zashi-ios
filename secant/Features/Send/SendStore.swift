import SwiftUI
import ComposableArchitecture

struct SendState: Equatable {
    var transaction: Transaction
    var route: Create.Route?
}

enum SendAction: Equatable {
    case updateTransaction(Transaction)
    case updateRoute(Create.Route?)
}

// Mark: - SendReducer

typealias SendReducer = Reducer<SendState, SendAction, Void>

extension SendReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = Reducer<SendState, SendAction, Void> { state, action, _ in
        switch action {
        case let .updateTransaction(transaction):
            state.transaction = transaction
            return .none
        case let .updateRoute(route):
            state.route = route
            return .none
        }
    }

    static func `default`(whenDone: @escaping () -> Void) -> SendReducer {
        SendReducer { state, action, _ in
            switch action {
            case let .updateRoute(route) where route == .showApprove(route: .showSent(route: .done)):
                return Effect.fireAndForget(whenDone)
            default:
                return Self.default.run(&state, action, ())
            }
        }
    }
}

// Mark: - SendStore

typealias SendStore = Store<SendState, SendAction>

// Mark: - SendViewStore

typealias SendViewStore = ViewStore<SendState, SendAction>

extension SendViewStore {

    var bindingForTransaction: Binding<Transaction> {
        self.binding(
            get: \.transaction,
            send: SendAction.updateTransaction
        )
    }

    var routeBinding: Binding<Create.Route?> {
        self.binding(
            get: \.route,
            send: SendAction.updateRoute
        )
    }
}

