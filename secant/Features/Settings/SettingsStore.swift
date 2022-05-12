import ComposableArchitecture

typealias SettingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>
typealias SettingsStore = Store<SettingsState, SettingsAction>
typealias SettingsViewStore = ViewStore<SettingsState, SettingsAction>

// MARK: - State

struct SettingsState: Equatable {
}

// MARK: - Action

enum SettingsAction: Equatable {
    case noOp
}

// MARK: - Environment

struct SettingsEnvironment: Equatable { }

// MARK: - Reducer

extension SettingsReducer {
    static let `default` = SettingsReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}
