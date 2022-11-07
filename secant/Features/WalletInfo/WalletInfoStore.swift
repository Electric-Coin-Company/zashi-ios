import ComposableArchitecture

struct WalletInfoReducer: ReducerProtocol {
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
