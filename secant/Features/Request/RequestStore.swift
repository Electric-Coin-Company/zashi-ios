import ComposableArchitecture

typealias RequestStore = Store<RequestReducer.State, RequestReducer.Action>

struct RequestReducer: ReducerProtocol {
    struct State: Equatable { }

    enum Action: Equatable {
        case noOp
    }

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        default:
            return .none
        }
    }
}

// MARK: Placeholders

extension RequestReducer.State {
    static var placeholder: Self {
        .init()
    }
}

extension RequestStore {
    static let placeholder = RequestStore(
        initialState: .placeholder,
        reducer: RequestReducer()
    )
}
