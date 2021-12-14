import ComposableArchitecture

struct WalletInfoState: Equatable {
}

enum WalletInfoAction: Equatable {
    case noOp
}

struct WalletInfoEnvironment: Equatable {
}

// MARK: - WalletInfoReducer

typealias WalletInfoReducer = Reducer<WalletInfoState, WalletInfoAction, WalletInfoEnvironment>

extension WalletInfoReducer {
    static let `default` = WalletInfoReducer { state, action, environment in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: - WalletInfoStore

typealias WalletInfoStore = Store<WalletInfoState, WalletInfoAction>

extension WalletInfoStore {
}

// MARK: - WalletInfoViewStore

typealias WalletInfoViewStore = ViewStore<WalletInfoState, WalletInfoAction>

extension WalletInfoViewStore {
}
