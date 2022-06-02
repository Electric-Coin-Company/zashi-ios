import ComposableArchitecture

typealias WalletInfoReducer = Reducer<WalletInfoState, WalletInfoAction, WalletInfoEnvironment>
typealias WalletInfoStore = Store<WalletInfoState, WalletInfoAction>
typealias WalletInfoViewStore = ViewStore<WalletInfoState, WalletInfoAction>

// MARK: - State

struct WalletInfoState: Equatable {
}

// MARK: - Action

enum WalletInfoAction: Equatable {
    case noOp
}

// MARK: - Environment

struct WalletInfoEnvironment {
}

// MARK: - Reducer

extension WalletInfoReducer {
    static let `default` = WalletInfoReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}
