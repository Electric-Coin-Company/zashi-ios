import SwiftUI
import ComposableArchitecture

struct SendState: Equatable {
    var transaction: Transaction
    var route: SendView.Route?
}

enum SendAction: Equatable {
    case updateTransaction(Transaction)
    case updateRoute(SendView.Route?)
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
            case let .updateRoute(route) where route == .done:
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

    var routeBinding: Binding<SendView.Route?> {
        self.binding(
            get: \.route,
            send: SendAction.updateRoute
        )
    }

    var bindingForApprove: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .showApprove || self.bindingForSent.wrappedValue },
            embed: { $0 ? SendView.Route.showApprove : nil }
        )
    }

    var bindingForSent: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .showSent || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendView.Route.showSent : SendView.Route.showApprove }
        )
    }

    var bindingForDone: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .done },
            embed: { $0 ? SendView.Route.done : SendView.Route.showSent }
        )
    }
}

