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
import AddressBookClient
import UIComponents
import TransactionDetails
import AddressBook

@Reducer
public struct TransactionList {
    public enum Constants {
        public static let homePageTransactionsCount = 5
    }
    
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    @ObservableState
    public struct State: Equatable {
        public var isInvalidated = true
        public var latestTransactionId = ""
        public var latestTransactionList: [TransactionState] = []
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var transactionList: IdentifiedArrayOf<TransactionState>
        public var transactionListHomePage: IdentifiedArrayOf<TransactionState> = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public init(
            latestTransactionList: [TransactionState] = [],
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.latestTransactionList = latestTransactionList
            self.transactionList = transactionList
            self.transactionListHomePage = IdentifiedArrayOf<TransactionState>(uniqueElements: transactionList.prefix(Constants.homePageTransactionsCount))
        }
    }

    public enum Action: Equatable {
        case foundTransactions
        case onAppear
        case onDisappear
        case synchronizerStateChanged(SyncStatus)
        case transactionTapped(String)
        case updateTransactionList([TransactionState])
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() {}

    // swiftlint:disable:next cyclomatic_complexity
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let selectedAccount = state.selectedWalletAccount
                return .merge(
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { TransactionList.Action.synchronizerStateChanged($0.syncStatus) }
                    }
                        .cancellable(id: CancelStateId, cancelInFlight: true),
                    .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions = $0 {
                                    return TransactionList.Action.foundTransactions
                                }
                                return nil
                            }
                    }
                    .cancellable(id: CancelEventId, cancelInFlight: true),
                    .run { send in
                        guard selectedAccount != nil else { return }
                        if let transactions = try? await sdkSynchronizer.getAllTransactions(selectedAccount?.id) {
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
                guard let accountUUID = state.selectedWalletAccount?.id else {
                    return .none
                }
                return .run { send in
                    if let transactions = try? await sdkSynchronizer.getAllTransactions(accountUUID) {
                        await send(.updateTransactionList(transactions))
                    }
                }
                
            case .synchronizerStateChanged:
                return .none
                
            case .foundTransactions:
                guard let accountUUID = state.selectedWalletAccount?.id else {
                    return .none
                }
                return .run { send in
                    if let transactions = try? await sdkSynchronizer.getAllTransactions(accountUUID) {
                        await send(.updateTransactionList(transactions))
                    }
                }
                
            case .updateTransactionList(let transactionList):
                state.isInvalidated = false
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
                            copiedTransaction.rawID = state.transactionList[index].rawID
                            copiedTransaction.memos = state.transactionList[index].memos
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
                state.transactionListHomePage = IdentifiedArrayOf(uniqueElements: sortedTransactionList.prefix(Constants.homePageTransactionsCount))
                state.latestTransactionId = state.transactionListHomePage.last?.id ?? ""
                
                return .none

            case .transactionTapped:
                return .none
            }
        }
    }
}
