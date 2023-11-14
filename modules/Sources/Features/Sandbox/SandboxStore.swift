import ComposableArchitecture
import SwiftUI
import TransactionList

public typealias SandboxStore = Store<SandboxReducer.State, SandboxReducer.Action>
public typealias SandboxViewStore = ViewStore<SandboxReducer.State, SandboxReducer.Action>

public struct SandboxReducer: ReducerProtocol {
    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case history
            case send
            case recoveryPhraseDisplay
            case scan
        }
        public var transactionListState: TransactionListReducer.State
        public var destination: Destination?
    }

    public enum Action: Equatable {
        case updateDestination(SandboxReducer.State.Destination?)
        case transactionList(TransactionListReducer.Action)
        case reset
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .updateDestination(destination):
            state.destination = destination
            return .none
            
        case let .transactionList(transactionListAction):
            return TransactionListReducer()
                .reduce(into: &state.transactionListState, action: transactionListAction)
                .map(SandboxReducer.Action.transactionList)
            
        case .reset:
            return .none
        }
    }
}

// MARK: - Store

extension SandboxStore {
    func historyStore() -> TransactionListStore {
        self.scope(
            state: \.transactionListState,
            action: SandboxReducer.Action.transactionList
        )
    }
}

// MARK: - ViewStore

extension SandboxViewStore {
    func bindingForDestination(_ destination: SandboxReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}

// MARK: - PlaceHolders

extension SandboxReducer.State {
    public static var placeholder: Self {
        .init(
            transactionListState: .placeholder,
            destination: nil
        )
    }
    
    public static var initial: Self {
        .init(
            transactionListState: .initial,
            destination: nil
        )
    }
}

extension SandboxStore {
    public static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxReducer.State(
                transactionListState: .placeholder,
                destination: nil
            ),
            reducer: SandboxReducer()
        )
    }
}
