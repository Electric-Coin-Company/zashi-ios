import ComposableArchitecture

struct RequestState: Equatable {
}

enum RequestAction: Equatable {
    case noOp
}

struct RequestEnvironment: Equatable {
}

// MARK: - RequestReducer

typealias RequestReducer = Reducer<RequestState, RequestAction, RequestEnvironment>

extension RequestReducer {
    static let `default` = RequestReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: - RequestStore

typealias RequestStore = Store<RequestState, RequestAction>

extension RequestStore {
}

// MARK: - RequestViewStore

typealias RequestViewStore = ViewStore<RequestState, RequestAction>

extension RequestViewStore {
}
