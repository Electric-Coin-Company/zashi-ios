//
//  TransactionsManagerStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-22-2025.
//

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
import AddressBook
import NumberFormatter
import UserMetadataProvider

@Reducer
public struct TransactionsManager {
    public struct Section: Equatable, Identifiable {
        public let id: String
        public var latestTransactionId = ""
        let timestamp: TimeInterval
        public let transactions: IdentifiedArrayOf<TransactionState>
    }
    
    public enum Filter: Equatable {
        case bookmarked
        case contact
        case memos
        case notes
        case received
        case sent
        case unread
    }

    @ObservableState
    public struct State: Equatable {
        public var CancelStateId = UUID()
        public var CancelEventId = UUID()

        public var activeFilters: [Filter] = []
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var filteredTransactionsList: IdentifiedArrayOf<TransactionState> = []
        public var filtersRequest = false
        public var isInvalidated = true
        public var latestTransactionList: [TransactionState] = []
        public var searchedTransactionsList: IdentifiedArrayOf<TransactionState> = []
        public var searchTerm = ""
        public var selectedFilters: [Filter] = []
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var transactionList: IdentifiedArrayOf<TransactionState>
        public var transactionSections: [Section] = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var isBookmarkedFilterActive: Bool { selectedFilters.contains(.bookmarked) }
        public var isContactFilterActive: Bool { selectedFilters.contains(.contact) }
        public var isMemosFilterActive: Bool { selectedFilters.contains(.memos) }
        public var isNotesFilterActive: Bool { selectedFilters.contains(.notes) }
        public var isReceivedFilterActive: Bool { selectedFilters.contains(.received) }
        public var isSentFilterActive: Bool { selectedFilters.contains(.sent) }
        public var isUnreadFilterActive: Bool { selectedFilters.contains(.unread) }

        public init(
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.transactionList = transactionList
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case asynchronousMemoSearchResult([String])
        case applyFiltersTapped
        case binding(BindingAction<TransactionsManager.State>)
        case eraseSearchTermTapped
        case filterTapped
        case foundTransactions
        case onAppear
        case onDisappear
        case resetFiltersTapped
        case synchronizerStateChanged(SyncStatus)
        case toggleFilter(Filter)
        case transactionTapped(String)
        case updateTransactionList([TransactionState])
        case updateTransactionPeriods
        case updateTransactionsAccordingToFilters
        case updateTransactionsAccordingToSearchTerm
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let selectedAccount = state.selectedWalletAccount
                if let abAccount = state.zashiWalletAccount {
                    do {
                        let result = try addressBook.allLocalContacts(abAccount.account)
                        let abContacts = result.contacts
                        if result.remoteStoreResult == .failure {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                        state.$addressBookContacts.withLock { $0 = abContacts }
                    } catch {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                    }
                }
                return .merge(
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { TransactionsManager.Action.synchronizerStateChanged($0.syncStatus) }
                    }
                    .cancellable(id: state.CancelStateId, cancelInFlight: true),
                    .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions = $0 {
                                    return TransactionsManager.Action.foundTransactions
                                }
                                return nil
                            }
                    }
                    .cancellable(id: state.CancelEventId, cancelInFlight: true),
                    .run { send in
                        guard selectedAccount != nil else { return }
                        if let transactions = try? await sdkSynchronizer.getAllTransactions(selectedAccount?.id) {
                            await send(.updateTransactionList(transactions))
                        }
                    }
                )
                
            case .onDisappear:
                return .concatenate(
                    .cancel(id: state.CancelStateId),
                    .cancel(id: state.CancelEventId)
                )
                
            case .binding(\.searchTerm):
                return .send(.updateTransactionsAccordingToSearchTerm)

            case .binding:
                return .none

            case .applyFiltersTapped:
                state.activeFilters = state.selectedFilters
                state.filtersRequest = false
                return .send(.updateTransactionsAccordingToSearchTerm)

            case .resetFiltersTapped:
                state.selectedFilters.removeAll()
                state.activeFilters.removeAll()
                return .send(.updateTransactionsAccordingToSearchTerm)

            case .eraseSearchTermTapped:
                state.searchTerm = ""
                return .send(.updateTransactionsAccordingToSearchTerm)
                
            case .filterTapped:
                state.selectedFilters = state.activeFilters
                state.filtersRequest = true
                return .none
                
            case .toggleFilter(let filter):
                if state.selectedFilters.contains(filter) {
                    state.selectedFilters.removeAll { $0 == filter }
                } else {
                    state.selectedFilters.append(filter)
                }
                return .none
                
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

            case .transactionTapped:
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
                
                return .send(.updateTransactionsAccordingToSearchTerm)
                
            case .updateTransactionsAccordingToSearchTerm:
                if !state.searchTerm.isEmpty && state.searchTerm.count >= 2 {
                    state.searchedTransactionsList.removeAll()

                    // synchronous search
                    state.transactionList.forEach { transaction in
                        if checkSearchTerm(state.searchTerm, transaction: transaction, addressBookContacts: state.addressBookContacts) {
                            state.searchedTransactionsList.append(transaction)
                        }
                    }

                    // asynchronous search
                    return .run { [searchTerm = state.searchTerm] send in
                        let txids = try? await sdkSynchronizer.fetchTxidsWithMemoContaining(searchTerm).map {
                            $0.toHexStringTxId()
                        }
                        
                        if let txids {
                            await send(.asynchronousMemoSearchResult(txids))
                        } else {
                            await send(.updateTransactionsAccordingToFilters)
                        }
                    }
                } else {
                    state.searchedTransactionsList = state.transactionList
                }
                
                return .send(.updateTransactionsAccordingToFilters)

            case .asynchronousMemoSearchResult(let txids):
                let results = state.transactionList.filter { txids.contains($0.id) }
                state.searchedTransactionsList.append(contentsOf: results)
                return .send(.updateTransactionsAccordingToFilters)
                
            case .updateTransactionsAccordingToFilters:
                // modify the initial list of all transactions according to active filters
                if !state.activeFilters.isEmpty {
                    state.filteredTransactionsList.removeAll()

                    state.searchedTransactionsList.forEach { transaction in
                        var isFilteredOut = false
                        
                        for i in 0..<state.activeFilters.count {
                            let filter = state.activeFilters[i]
                            
                            if !filter.applyFilter(
                                transaction,
                                addressBookContacts: state.addressBookContacts,
                                userMetadataProvider: userMetadataProvider
                            ) {
                                isFilteredOut = true
                                break
                            }
                        }
                        
                        if !isFilteredOut {
                            state.filteredTransactionsList.append(transaction)
                        }
                    }
                } else {
                    state.filteredTransactionsList = state.searchedTransactionsList
                }

                return .send(.updateTransactionPeriods)
                
            case .updateTransactionPeriods:
                state.transactionSections.removeAll()

                // divide the filtered list of transactions into a time periods
                let grouped = Dictionary(grouping: state.filteredTransactionsList) { transaction in
                    guard let timestamp = transaction.timestamp else { return L10n.Filter.today }

                    let calendar = Calendar.current
                    let startOfToday = calendar.startOfDay(for: Date())
                    let startOfGivenDate = calendar.startOfDay(for: Date(timeIntervalSince1970: timestamp))

                    return getTimePeriod(for: startOfGivenDate, now: startOfToday)
                }

                let sections = grouped.map { key, transactions in
                    var timestamp: TimeInterval = Date().timeIntervalSince1970
                    
                    for transaction in transactions {
                        if transaction.timestamp != nil {
                            timestamp = transaction.timestamp ?? 0
                            break
                        }
                    }
                    
                    return Section(
                        id: key,
                        latestTransactionId: transactions.last?.id ?? "",
                        timestamp: timestamp,
                        transactions: IdentifiedArrayOf<TransactionState>(uniqueElements: transactions)
                    )
                }
                
                let sortedSections = sections.sorted { lhs, rhs in
                    lhs.timestamp > rhs.timestamp
                }
                
                sortedSections.forEach { section in
                    state.transactionSections.append(section)
                }

                return .none
            }
        }
    }
}

extension TransactionsManager {
    func getTimePeriod(for date: Date, now: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: now)
        let daysAgo = components.day ?? Int.max
        
        if Calendar.current.isDateInToday(date) {
            return L10n.Filter.today
        } else if Calendar.current.isDateInYesterday(date) {
            return L10n.Filter.yesterday
        } else if daysAgo < 7 {
            return L10n.Filter.previous7days
        } else if daysAgo < 31 {
            return L10n.Filter.previous30days
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    func unicodeContains(_ searchTerm: String, in text: String) -> Bool {
        let normalizedText = text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        let normalizedSearchTerm = searchTerm.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        
        return normalizedText.range(of: normalizedSearchTerm) != nil
    }
    
    func checkSearchTerm(_ searchTerm: String, transaction: TransactionState, addressBookContacts: AddressBookContacts) -> Bool {
        // search contact name
        if addressBookContacts.contacts.contains(where: {
            $0.id == transaction.address && unicodeContains(searchTerm, in: $0.name)
        }) {
            return true
        }
        
        // search address
        if unicodeContains(searchTerm, in: transaction.address) {
            return true
        }

        // Regex amounts
        var input = transaction.totalAmount.decimalString()
        
        if transaction.isSpending {
            input = "-\(input)"
        }
        
        let pattern = "([<>])\\s*(-?(?:0|(?=\\.))?\\d*(?:[.,]\\d+)?)"
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: searchTerm, range: NSRange(searchTerm.startIndex..., in: searchTerm)) {
            
            if let operatorRange = Range(match.range(at: 1), in: searchTerm),
               let numberRange = Range(match.range(at: 2), in: searchTerm),
               let threshold = numberFormatter.number(String(searchTerm[numberRange])) {
                let op = String(searchTerm[operatorRange])
                
                if let amount = numberFormatter.number(input) {
                    if op == "<" {
                        return amount.doubleValue < threshold.doubleValue
                    } else if op == ">" {
                        return amount.doubleValue > threshold.doubleValue
                    }
                }
            }
        }
        
        // fullsearch amounts
        if input.contains(searchTerm) {
            return true
        }
        
        // fullsearch annotations
        if let annotation = userMetadataProvider.annotationFor(transaction.id), annotation.contains(searchTerm) {
            return true
        }

        return false
    }
    
}

extension TransactionsManager.Filter {
    func applyFilter(
        _ transaction: TransactionState,
        addressBookContacts: AddressBookContacts,
        userMetadataProvider: UserMetadataProviderClient
    ) -> Bool {
        switch self {
        case .bookmarked:
            return userMetadataProvider.isBookmarked(transaction.id)
        case .contact:
            return addressBookContacts.contacts.contains(where: { $0.id == transaction.address })
        case .memos:
            return transaction.memoCount > 0
        case .notes:
            return userMetadataProvider.annotationFor(transaction.id) != nil
        case .received:
            return !transaction.isSentTransaction
        case .sent:
            return transaction.isSentTransaction
        case .unread:
            return true
        }
    }
}
