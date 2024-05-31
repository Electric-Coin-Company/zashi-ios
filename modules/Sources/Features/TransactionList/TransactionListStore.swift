import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils
import Models
import Generated
import Pasteboard
import SDKSynchronizer
import ReadTransactionsStorage
import ZcashSDKEnvironment

public typealias TransactionListStore = Store<TransactionListReducer.State, TransactionListReducer.Action>
public typealias TransactionListViewStore = ViewStore<TransactionListReducer.State, TransactionListReducer.Action>

public struct TransactionListReducer: Reducer {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    public struct State: Equatable {
        public var latestMinedHeight: BlockHeight?
        public var requiredTransactionConfirmations = 0
        public var latestTransactionList: [TransactionState] = []
        public var transactionList: IdentifiedArrayOf<TransactionState>
        public var latestTranassctionId = ""
        
        public init(
            latestMinedHeight: BlockHeight? = nil,
            requiredTransactionConfirmations: Int = 0,
            latestTransactionList: [TransactionState] = [],
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.latestMinedHeight = latestMinedHeight
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.latestTransactionList = latestTransactionList
            self.transactionList = transactionList
        }
    }

    public enum Action: Equatable {
        case copyToPastboard(RedactableString)
        case foundTransactions
        case memosFor([Memo], String)
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
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage

    public init() {}
    
    // swiftlint:disable:next cyclomatic_complexity
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations
            
            return .merge(
                .publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map { TransactionListReducer.Action.synchronizerStateChanged($0.syncStatus) }
                }
                .cancellable(id: CancelStateId, cancelInFlight: true),
                .publisher {
                    sdkSynchronizer.eventStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .compactMap {
                            if case SynchronizerEvent.foundTransactions = $0 {
                                return TransactionListReducer.Action.foundTransactions
                            }
                            return nil
                        }
                }
                .cancellable(id: CancelEventId, cancelInFlight: true),
                .run { send in
                    if let transactions = try? await sdkSynchronizer.getAllTransactions() {
                        await send(.updateTransactionList(transactions))
                    }
                }
            )

        case .onDisappear:
            return .concatenate(
                .cancel(id: CancelStateId),
                .cancel(id: CancelEventId)
            )

        case .synchronizerStateChanged(.upToDate):
            state.latestMinedHeight = sdkSynchronizer.latestState().latestBlockHeight
            return .run { send in
                if let transactions = try? await sdkSynchronizer.getAllTransactions() {
                    await send(.updateTransactionList(transactions))
                }
            }
            
        case .synchronizerStateChanged:
            return .none
        
        case .foundTransactions:
            return .run { send in
                if let transactions = try? await sdkSynchronizer.getAllTransactions() {
                    await send(.updateTransactionList(transactions))
                }
            }

        case .updateTransactionList(let transactionList):
            // update the list only if there is anything new
            guard state.latestTransactionList != transactionList else {
                return .none
            }
            state.latestTransactionList = transactionList
            
            var readIds: [RedactableString: Bool] = [:]
            if let ids = try? readTransactionsStorage.readIds() {
                readIds = ids
            }
            
            let timestamp: TimeInterval = (try? readTransactionsStorage.availabilityTimestamp()) ?? 0
            
            let mempoolHeight = sdkSynchronizer.latestState().latestBlockHeight + 1
            
            let sortedTransactionList = transactionList
                .sorted(by: { lhs, rhs in
                    lhs.transactionListHeight(mempoolHeight) > rhs.transactionListHeight(mempoolHeight)
                }).map { transaction in
                    var copiedTransaction = transaction
                    
                    // update the expanded states
                    if let index = state.transactionList.index(id: transaction.id) {
                        copiedTransaction.isAddressExpanded = state.transactionList[index].isAddressExpanded
                        copiedTransaction.isExpanded = state.transactionList[index].isExpanded
                        copiedTransaction.isIdExpanded = state.transactionList[index].isIdExpanded
                        copiedTransaction.rawID = state.transactionList[index].rawID
                    }
                    
                    // update the read/unread state
                    if !transaction.isSpending {
                        if let tsTimestamp = copiedTransaction.timestamp, tsTimestamp > timestamp {
                            copiedTransaction.isMarkedAsRead = readIds[copiedTransaction.id.redacted] ?? false
                        } else {
                            copiedTransaction.isMarkedAsRead = true
                        }
                    }

                    return copiedTransaction
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
                
                // presence of the rawID is a sign that memos hasn't been loaded yet
                if let rawID = state.transactionList[index].rawID {
                    return .run { send in
                        if let memos = try? await sdkSynchronizer.getMemos(rawID) {
                            await send(.memosFor(memos, id))
                        }
                    }
                }

                // update of the unread state
                if !state.transactionList[index].isSpending
                    && !state.transactionList[index].isMarkedAsRead
                    && state.transactionList[index].isUnread {
                    do {
                        try readTransactionsStorage.markIdAsRead(state.transactionList[index].id.redacted)
                        state.transactionList[index].isMarkedAsRead = true
                    } catch { }
                }
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
            
        case let .memosFor(memos, id):
            if let index = state.transactionList.index(id: id) {
                // deduplicate memos
                var finalMemos: [Memo] = []

                for memo in memos {
                    guard let textMemo = memo.toString() else {
                        continue
                    }

                    var duplicate = false
                    for checkMemo in finalMemos {
                        if let checkMemoText = checkMemo.toString(), checkMemoText == textMemo {
                            duplicate = true
                            break
                        }
                    }
                    
                    if !duplicate {
                        finalMemos.append(memo)
                    }
                }
                
                state.transactionList[index].rawID = nil
                state.transactionList[index].memos = finalMemos
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
    public static var placeholder: Self {
        .init(transactionList: .mocked)
    }

    public static var initial: Self {
        .init(transactionList: [])
    }
}

extension TransactionListStore {
    public static var placeholder: Store<TransactionListReducer.State, TransactionListReducer.Action> {
        Store(
            initialState: .placeholder
        ) {
            TransactionListReducer()
                .dependency(\.zcashSDKEnvironment, .testnet)
        }
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    public static var placeholder: IdentifiedArrayOf<TransactionState> {
        .init(
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
        .init(
            uniqueElements: [
                TransactionState.mockedSent,
                TransactionState.mockedReceived
            ]
        )
    }
}
