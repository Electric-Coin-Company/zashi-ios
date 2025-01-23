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

@Reducer
public struct TransactionsManager {
    @ObservableState
    public struct State: Equatable {
        public var CancelStateId = UUID()
        public var CancelEventId = UUID()

        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var isInvalidated = true
        public var latestTransactionId = ""
        public var latestTransactionList: [TransactionState] = []
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var transactionList: IdentifiedArrayOf<TransactionState>
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public init(
            transactionList: IdentifiedArrayOf<TransactionState>
        ) {
            self.transactionList = transactionList
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

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
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
                state.latestTransactionId = state.transactionList.first?.id ?? ""
                
                return .none
            }
        }
    }
}
