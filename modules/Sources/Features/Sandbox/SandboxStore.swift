import ComposableArchitecture
import SwiftUI
import TransactionList

@Reducer
public struct Sandbox {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case history
            case send
            case recoveryPhraseDisplay
            case scan
        }
        public var transactionListState: TransactionList.State
        public var destination: Destination?
    }

    public enum Action: Equatable {
        case updateDestination(Sandbox.State.Destination?)
        case transactionList(TransactionList.Action)
        case reset
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
        case let .updateDestination(destination):
            state.destination = destination
            return .none
            
        case let .transactionList(transactionListAction):
            return TransactionList()
                .reduce(into: &state.transactionListState, action: transactionListAction)
                .map(Sandbox.Action.transactionList)
            
        case .reset:
            return .none
        }
    }
}
