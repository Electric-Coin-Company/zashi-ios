import ComposableArchitecture

struct ScanState: Equatable {
}

enum ScanAction: Equatable {
    case noOp
}

struct ScanEnvironment {
}

// MARK: - ScanReducer

typealias ScanReducer = Reducer<ScanState, ScanAction, ScanEnvironment>

extension ScanReducer {
    static let `default` = ScanReducer { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}

// MARK: - ScanStore

typealias ScanStore = Store<ScanState, ScanAction>

extension ScanStore {
    static let placeholder = ScanStore(
        initialState: .placeholder,
        reducer: .default,
        environment: ScanEnvironment()
    )
}

// MARK: - ScanViewStore

typealias ScanViewStore = ViewStore<ScanState, ScanAction>

extension ScanViewStore {
}

// MARK: PlaceHolders

extension ScanState {
    static var placeholder: Self {
        .init()
    }
}
