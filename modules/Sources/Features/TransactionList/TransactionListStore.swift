import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils
import Models
import Generated
import Pasteboard
import SDKSynchronizer
import ZcashSDKEnvironment

public typealias TransactionListStore = Store<TransactionListReducer.State, TransactionListReducer.Action>
public typealias TransactionListViewStore = ViewStore<TransactionListReducer.State, TransactionListReducer.Action>

public struct TransactionListReducer: ReducerProtocol {
    private enum CancelId { case timer }

    public struct State: Equatable {
        public var latestMinedHeight: BlockHeight?
        public var isScrollable = true
        public var requiredTransactionConfirmations = 0
        public var transactionList: IdentifiedArrayOf<TransactionState>
        public var latestTranassctionId = ""
        
        public init(
            latestMinedHeight: BlockHeight? = nil,
            isScrollable: Bool = true,
            requiredTransactionConfirmations: Int = 0,
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.latestMinedHeight = latestMinedHeight
            self.isScrollable = isScrollable
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.transactionList = transactionList
        }
    }

    public enum Action: Equatable {
        case copyToPastboard(RedactableString)
        case onAppear
        case onDisappear
        case synchronizerStateChanged(SyncStatus)
        case transactionCollapseRequested(String)
        case transactionAddressExpandRequested(String)
        case transactionExpandRequested(String)
        case transactionIdExpandRequested(String)
        case updateTransactionList([TransactionState])
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() {}
    
    // swiftlint:disable:next cyclomatic_complexity
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations
            return .merge(
                sdkSynchronizer.stateStream()
                    .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                    .map { TransactionListReducer.Action.synchronizerStateChanged($0.syncStatus) }
                    .eraseToEffect()
                    .cancellable(id: CancelId.timer, cancelInFlight: true),
                .run { send in
                    await send(.updateTransactionList(try await sdkSynchronizer.getAllTransactions()))
                }
            )

        case .onDisappear:
            return .cancel(id: CancelId.timer)

        case .synchronizerStateChanged(.upToDate):
            state.latestMinedHeight = sdkSynchronizer.latestState().latestBlockHeight
            return .task {
                return .updateTransactionList(try await sdkSynchronizer.getAllTransactions())
            }
            
        case .synchronizerStateChanged:
            return .none
            
        case .updateTransactionList(let transactionList):
            let sortedTransactionList = transactionList
                .sorted(by: { lhs, rhs in
                    guard let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp else {
                        return false
                    }
                    return lhsTimestamp > rhsTimestamp
                }).map { transaction in
                    if let index = state.transactionList.index(id: transaction.id) {
                        var copiedTransaction = transaction
                        
                        copiedTransaction.isAddressExpanded = state.transactionList[index].isAddressExpanded
                        copiedTransaction.isExpanded = state.transactionList[index].isExpanded
                        copiedTransaction.isIdExpanded = state.transactionList[index].isIdExpanded

                        return copiedTransaction
                    }
                    
                    return transaction
                }
            state.transactionList = IdentifiedArrayOf(uniqueElements: sortedTransactionList)
            state.latestTranassctionId = state.transactionList.first?.id ?? ""
            return .none
            
        case .copyToPastboard(let value):
            pasteboard.setString(value)
            return .none

        case .transactionCollapseRequested(let id):
            if let index = state.transactionList.index(id: id) {
                state.transactionList[index].isAddressExpanded = false
                state.transactionList[index].isExpanded = false
                state.transactionList[index].isIdExpanded = false
            }
            return .none

        case .transactionAddressExpandRequested(let id):
            if let index = state.transactionList.index(id: id) {
                if state.transactionList[index].isExpanded {
                    state.transactionList[index].isAddressExpanded = true
                } else {
                    state.transactionList[index].isExpanded = true
                }
            }
            return .none

        case .transactionExpandRequested(let id):
            if let index = state.transactionList.index(id: id) {
                state.transactionList[index].isExpanded = true
            }
            return .none

        case .transactionIdExpandRequested(let id):
            if let index = state.transactionList.index(id: id) {
                if state.transactionList[index].isExpanded {
                    state.transactionList[index].isIdExpanded = true
                } else {
                    state.transactionList[index].isExpanded = true
                }
            }
            return .none
        }
    }
}

// MARK: ViewStore

extension TransactionListViewStore {
    func isLatestTransaction(id: String) -> Bool {
        state.latestTranassctionId == id
    }
}

// MARK: Placeholders

extension TransactionListReducer.State {
    public static var placeHolder: Self {
        .init(transactionList: .mocked)
    }

    public static var emptyPlaceHolder: Self {
        .init(transactionList: [])
    }
}

extension TransactionListStore {
    public static var placeholder: Store<TransactionListReducer.State, TransactionListReducer.Action> {
        return Store(
            initialState: .placeHolder,
            reducer: TransactionListReducer()
                .dependency(\.zcashSDKEnvironment, .testnet)
        )
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    public static var placeholder: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(10),
                    id: String($0),
                    status: .paid,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(25)
                )
            }
        )
    }
    
    public static var mocked: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: [
                TransactionState.mockedSent,
                TransactionState.mockedReceived
            ]
        )
    }
}
