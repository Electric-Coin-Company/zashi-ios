import ComposableArchitecture

struct SettingsState: Equatable {
}

enum SettingsAction: Equatable {
    case noOp
}

struct SettingsEnvironment: Equatable {
}

// MARK: - SettingsStateReducer

typealias SettingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>

extension SettingsReducer {
    static let `default` = SettingsReducer { state, action, environment in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: - SettingsStore

typealias SettingsStore = Store<SettingsState, SettingsAction>

extension SettingsStore {
}

// MARK: - SettingsViewStore

typealias SettingsViewStore = ViewStore<SettingsState, SettingsAction>

extension SettingsViewStore {
}
