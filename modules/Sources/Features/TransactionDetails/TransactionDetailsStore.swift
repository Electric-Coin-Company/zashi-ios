//
//  TransactionDetailsStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-08-2024
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
import AddressBookClient

@Reducer
public struct TransactionDetails {
    @ObservableState
    public struct State: Equatable {
        enum Constants {
            static let messageExpandThreshold = 130
        }
        
        public enum MessageState: Equatable {
            case longCollapsed
            case longExpanded
            case short
        }
        
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var alias: String?
        public var areDetailsExpanded = false
        public var messageStates: [MessageState] = []
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil
        public var transaction: TransactionState
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var feeStr: String {
            transaction.fee?.decimalString() ?? "0.001"
        }
        
        public var memos: [String] {
            if let memos = transaction.memos {
                return memos.compactMap { $0.toString() }
            }
            
            return []
        }
        
        public init(
            transaction: TransactionState
        ) {
            self.transaction = transaction
        }
    }
    
    public enum Action: Equatable {
        case addNoteTapped
        case addressTapped
        case bookmarkTapped
        case fetchedABContacts(AddressBookContacts)
        case memosLoaded([Memo])
        case messageTapped(Int)
        case onAppear
        case resolveMemos
        case saveAddressTapped
        case sendAgainTapped
        case sentToRowTapped
        case transactionIdTapped
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.areDetailsExpanded = false
                state.messageStates = []
                state.alias = nil
                if let account = state.zashiWalletAccount {
                    do {
                        let result = try addressBook.allLocalContacts(account.account)
                        let abContacts = result.contacts
                        if result.remoteStoreResult == .failure {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                        return .merge(
                            .send(.resolveMemos),
                            .send(.fetchedABContacts(abContacts))
                        )
                    } catch {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        return .send(.resolveMemos)
                    }
                }
                return .send(.resolveMemos)

            case .resolveMemos:
                if let rawID = state.transaction.rawID {
                    return .run { send in
                        if let memos = try? await sdkSynchronizer.getMemos(rawID) {
                            await send(.memosLoaded(memos))
                        }
                    }
                }
                return .none

            case .fetchedABContacts(let abContacts):
                state.$addressBookContacts.withLock { $0 = abContacts }
                state.alias = nil
                for contact in state.addressBookContacts.contacts {
                    if contact.id == state.transaction.address {
                        state.alias = contact.name
                        break
                    }
                }
                return .none
                
            case .memosLoaded(let memos):
                state.transaction.memos = memos
                state.messageStates = state.memos.map {
                    $0.count < State.Constants.messageExpandThreshold ? .short : .longCollapsed
                }
                return .none

            case .addNoteTapped:
                return .none

            case .bookmarkTapped:
                return .none

            case .messageTapped(let index):
                if index < state.messageStates.count && state.messageStates[index] != .short {
                    if state.messageStates[index] == .longExpanded {
                        state.messageStates[index] = .longCollapsed
                    } else {
                        state.messageStates[index] = .longExpanded
                    }
                }
                return .none

            case .saveAddressTapped:
                return .none
                
            case .sendAgainTapped:
                return .none
                
            case .sentToRowTapped:
                state.areDetailsExpanded.toggle()
                return .none
                
            case .addressTapped:
                pasteboard.setString(state.transaction.address.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none

            case .transactionIdTapped:
                pasteboard.setString(state.transaction.id.redacted)
                state.$toast.withLock { $0 = .top(L10n.General.copiedToTheClipboard) }
                return .none
            }
        }
    }
}
