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
import UserMetadataProvider

@Reducer
public struct TransactionDetails {
    @ObservableState
    public struct State: Equatable {
        enum Constants {
            static let messageExpandThreshold: Int = 130
            static let annotationMaxLength: Int = 90
        }
        
        public enum MessageState: Equatable {
            case longCollapsed
            case longExpanded
            case short
        }
        
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var areMessagesResolved = false
        public var alias: String?
        public var areDetailsExpanded = false
        public var isEditMode = false
        public var isBookmarked = false
        @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
        public var messageStates: [MessageState] = []
        public var annotation = ""
        public var annotationOrigin = ""
        @Shared(.inMemory(.toast)) public var toast: Toast.Edge? = nil
        public var transaction: TransactionState
        public var annotationRequest = false
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var feeStr: String {
            transaction.fee?.decimalString() ?? L10n.TransactionHistory.defaultFee
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
    
    public enum Action: BindableAction, Equatable {
        case addNoteTapped
        case addressTapped
        case binding(BindingAction<TransactionDetails.State>)
        case bookmarkTapped
        case deleteNoteTapped
        case fetchedABContacts(AddressBookContacts)
        case memosLoaded([Memo])
        case messageTapped(Int)
        case noteButtonTapped
        case onAppear
        case resolveMemos
        case saveAddressTapped
        case saveNoteTapped
        case sendAgainTapped
        case sentToRowTapped
        case transactionIdTapped
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userMetadataProvider) var userMetadataProvider

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.areDetailsExpanded = false
                state.messageStates = []
                state.alias = nil
                state.areMessagesResolved = false
                state.isBookmarked = userMetadataProvider.isBookmarked(state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationOrigin = state.annotation
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

            case .binding(\.annotation):
                if state.annotation.count > TransactionDetails.State.Constants.annotationMaxLength {
                    state.annotation = String(state.annotation.prefix(TransactionDetails.State.Constants.annotationMaxLength))
                }
                return .none
                
            case .binding:
                return .none

            case .deleteNoteTapped:
                userMetadataProvider.deleteAnnotationFor(state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationRequest = false
                return .none

            case .saveNoteTapped, .addNoteTapped:
                userMetadataProvider.addAnnotationFor(state.annotation, state.transaction.id)
                state.annotation = userMetadataProvider.annotationFor(state.transaction.id) ?? ""
                state.annotationOrigin = ""
                state.annotationRequest = false
                return .none

            case .resolveMemos:
                if let rawID = state.transaction.rawID {
                    return .run { send in
                        if let memos = try? await sdkSynchronizer.getMemos(rawID) {
                            await send(.memosLoaded(memos))
                        }
                    }
                }
                state.areMessagesResolved = true
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
                state.areMessagesResolved = true
                return .none

            case .noteButtonTapped:
                state.isEditMode = !state.annotation.isEmpty
                state.annotationOrigin = state.annotation
                state.annotationRequest = true
                return .none

            case .bookmarkTapped:
                userMetadataProvider.toggleBookmarkFor(state.transaction.id)
                state.isBookmarked = userMetadataProvider.isBookmarked(state.transaction.id)
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
