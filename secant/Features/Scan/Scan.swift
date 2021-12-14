import ComposableArchitecture

struct ScanState: Equatable {
}

enum ScanAction: Equatable {
    case noOp
}

struct ScanEnvironment: Equatable {
}

// MARK: - ScanReducer

typealias ScanReducer = Reducer<ScanState, ScanAction, ScanEnvironment>

extension ScanReducer {
    static let `default` = ScanReducer { state, action, environment in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: - ScanStore

typealias ScanStore = Store<ScanState, ScanAction>

extension ScanStore {
}

// MARK: - ScanViewStore

typealias ScanViewStore = ViewStore<ScanState, ScanAction>

extension ScanViewStore {
}
