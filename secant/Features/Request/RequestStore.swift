import ComposableArchitecture

typealias RequestReducer = Reducer<RequestState, RequestAction, RequestEnvironment>
typealias RequestStore = Store<RequestState, RequestAction>
typealias RequestViewStore = ViewStore<RequestState, RequestAction>

// MARK: - State

struct RequestState: Equatable {
}

// MARK: - Action

enum RequestAction: Equatable {
    case noOp
}

// MARK: - Environment

struct RequestEnvironment { }

// MARK: - Reducer

extension RequestReducer {
    static let `default` = RequestReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: Placeholders

extension RequestState {
    static var placeholder: Self {
        .init()
    }
}

extension RequestStore {
    static let placeholder = RequestStore(
        initialState: .placeholder,
        reducer: .default,
        environment: RequestEnvironment()
    )
}
