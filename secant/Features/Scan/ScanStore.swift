import ComposableArchitecture

typealias ScanReducer = Reducer<ScanState, ScanAction, ScanEnvironment>
typealias ScanStore = Store<ScanState, ScanAction>
typealias ScanViewStore = ViewStore<ScanState, ScanAction>

// MARK: - State

struct ScanState: Equatable {
}

// MARK: - Action

enum ScanAction: Equatable {
    case noOp
}

// MARK: - Environment

struct ScanEnvironment { }

// MARK: - Reducer

extension ScanReducer {
    static let `default` = ScanReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: Placeholders

extension ScanState {
    static var placeholder: Self {
        .init()
    }
}

extension ScanStore {
    static let placeholder = ScanStore(
        initialState: .placeholder,
        reducer: .default,
        environment: ScanEnvironment()
    )
}
