import SwiftUI
import ComposableArchitecture

struct Transaction: Equatable {
    var amount: UInt
    var memo: String
    var toAddress: String
}

extension Transaction {
    static var placeholder: Self {
        .init(
            amount: 10000,
            memo: "Hi, sending you lorem ipsum",
            toAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
        )
    }
}

struct SendState: Equatable {
    enum Route: Equatable {
        case showConfirmation
        case showSent
        case done
    }

    var transaction: Transaction
    var route: Route?
}

enum SendAction: Equatable {
    case sendConfirmationPressed
    case updateTransaction(Transaction)
    case updateRoute(SendState.Route?)
}

struct SendEnvironment {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let wrappedSDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - SendReducer

typealias SendReducer = Reducer<SendState, SendAction, SendEnvironment>

extension SendReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = Reducer<SendState, SendAction, SendEnvironment> { state, action, environment in
        switch action {
        case let .updateTransaction(transaction):
            state.transaction = transaction
            return .none
            
        case let .updateRoute(route):
            state.route = route
            return .none
            
        case .sendConfirmationPressed:
            print("sending")
            //environment.wrappedSDKSynchronizer.
            return .none
        }
    }

    static func `default`(whenDone: @escaping () -> Void) -> SendReducer {
        SendReducer { state, action, environment in
            switch action {
            case let .updateRoute(route) where route == .done:
                return Effect.fireAndForget(whenDone)
            default:
                return Self.default.run(&state, action, environment)
            }
        }
    }
}

// MARK: - SendStore

typealias SendStore = Store<SendState, SendAction>

// MARK: - SendViewStore

typealias SendViewStore = ViewStore<SendState, SendAction>

extension SendViewStore {
    var bindingForTransaction: Binding<Transaction> {
        self.binding(
            get: \.transaction,
            send: SendAction.updateTransaction
        )
    }

    var routeBinding: Binding<SendState.Route?> {
        self.binding(
            get: \.route,
            send: SendAction.updateRoute
        )
    }

    var bindingForConfirmation: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .showConfirmation },
            embed: { $0 ? SendState.Route.showConfirmation : nil }
        )
    }
}

// MARK: PlaceHolders

extension SendState {
    static var placeholder: Self {
        .init(transaction: .placeholder, route: nil)
    }

    static var emptyPlaceholder: Self {
        .init(
            transaction: .init(
                amount: 0,
                memo: "",
                toAddress: ""
            ),
            route: nil
        )
    }
}
