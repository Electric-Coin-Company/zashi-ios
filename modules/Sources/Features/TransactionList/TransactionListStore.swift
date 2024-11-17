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

@Reducer
public struct TransactionList {
    private let CancelStateId = UUID()
    private let CancelEventId = UUID()

    @ObservableState
    public struct State: Equatable {
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var latestMinedHeight: BlockHeight?
        public var latestTransactionId = ""
        public var latestTransactionList: [TransactionState] = []
        public var requiredTransactionConfirmations = 0
        public var transactionList: IdentifiedArrayOf<TransactionState>

        public init(
            latestMinedHeight: BlockHeight? = nil,
            latestTransactionList: [TransactionState] = [],
            requiredTransactionConfirmations: Int = 0,
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.latestMinedHeight = latestMinedHeight
            self.latestTransactionList = latestTransactionList
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.transactionList = transactionList
        }
    }

    public enum Action: Equatable {
        case copyToPastboard(RedactableString)
        case fetchedABContacts(AddressBookContacts)
        case foundTransactions
        case memosFor([Memo], String)
        case onAppear
        case onDisappear
        case saveAddressTapped(RedactableString)
        case synchronizerStateChanged(SyncStatus)
        case transactionCollapseRequested(String)
        case transactionAddressExpandRequested(String)
        case transactionExpandRequested(String)
        case transactionIdExpandRequested(String)
        case updateTransactionList([TransactionState])
    }
    
    @Dependency(\.addressBook) var addressBook
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
            do {
                let result = try addressBook.allLocalContacts()
                let abContacts = result.contacts
                if result.remoteStoreResult == .failure {
                    // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                }
                state.addressBookContacts = abContacts
            } catch {
                // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
            }

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
                    if let transactions = try? await sdkSynchronizer.getAllTransactions() {
                        await send(.updateTransactionList(transactions))
                    }
                }
            )
            
        case .fetchedABContacts(let abContacts):
            state.addressBookContacts = abContacts
            let modifiedTransactionState = state.transactionList.map { transaction in
                var copiedTransaction = transaction
                
                copiedTransaction.isInAddressBook = false
                for contact in state.addressBookContacts.contacts {
                    if contact.id == transaction.address {
                        copiedTransaction.isInAddressBook = true
                        break
                    }
                }
                
                return copiedTransaction
            }
            state.transactionList = IdentifiedArrayOf(uniqueElements: modifiedTransactionState)
            return .none

        case .onDisappear:
            return .concatenate(
                .cancel(id: CancelStateId),
                .cancel(id: CancelEventId)
            )

        case .saveAddressTapped:
            return .none
            
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
                    
                    // in address book
                    copiedTransaction.isInAddressBook = false
                    for contact in state.addressBookContacts.contacts {
                        if contact.id == transaction.address {
                            copiedTransaction.isInAddressBook = true
                            break
                        }
                    }

                    return copiedTransaction
                }
            
            state.transactionList = IdentifiedArrayOf(uniqueElements: sortedTransactionList)
            state.latestTransactionId = state.transactionList.first?.id ?? ""

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
                    for contact in state.addressBookContacts.contacts {
                        if contact.id == state.transactionList[index].address {
                            state.transactionList[index].isInAddressBook = true
                            break
                        }
                    }
                } else {
                    state.transactionList[index].isExpanded = true
                }
            }
            return .none

        case .transactionExpandRequested(let id):
            if let index = state.transactionList.index(id: id) {
                state.transactionList[index].isExpanded = true
                
                // update of the unread state
                if !state.transactionList[index].isSpending
                    && !state.transactionList[index].isMarkedAsRead
                    && state.transactionList[index].isUnread {
                    do {
                        try readTransactionsStorage.markIdAsRead(state.transactionList[index].id.redacted)
                        state.transactionList[index].isMarkedAsRead = true
                    } catch { }
                }

                // presence of the rawID is a sign that memos hasn't been loaded yet
                if let rawID = state.transactionList[index].rawID {
                    return .run { send in
                        if let memos = try? await sdkSynchronizer.getMemos(rawID) {
                            await send(.memosFor(memos, id))
                        }
                    }
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
