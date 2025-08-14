//
//  AddressBookStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import ComposableArchitecture
import SwiftUI

import AddressBookClient
import DerivationTool
import Generated
import Models
import ZcashSDKEnvironment
import AudioServices
import ZcashLightClientKit

@Reducer
public struct AddressBook {
    enum Constants {
        static let maxNameLength = 32
    }
    
    @ObservableState
    public struct State: Equatable {
        public var address = ""
        public var addressAlreadyExists = false
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        @Presents public var alert: AlertState<Action>?
        public var chain = ""
        public var deleteIdToConfirm: String?
        public var isAddressFocused = false
        public var editId: String?
        public var isChainFocused = false
        public var isInSelectMode = false
        public var isNameFocused = false
        public var isTokenFocused = false
        public var isValidForm = false
        public var isValidZcashAddress = false
        public var name = ""
        public var nameAlreadyExists = false
        public var originalAddress = ""
        public var originalName = ""
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var token = ""
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var isEditChange: Bool {
            (address != originalAddress || name != originalName) && isValidForm
        }
        
        public var isNameOverMaxLength: Bool {
            name.count > Constants.maxNameLength
        }

        public var isSaveButtonDisabled: Bool {
            !isEditChange
            || isNameOverMaxLength
            || nameAlreadyExists
            || addressAlreadyExists
        }
        
        public var invalidAddressErrorText: String? {
            addressAlreadyExists
            ? L10n.AddressBook.Error.addressExists
            : (isValidZcashAddress || address.isEmpty)
            ? nil
            : L10n.AddressBook.Error.invalidAddress
        }

        public var invalidNameErrorText: String? {
            isNameOverMaxLength
            ? L10n.AddressBook.Error.nameLength
            : nameAlreadyExists
            ? L10n.AddressBook.Error.nameExists
            : nil
        }

        public init() { }
    }

    public enum Action: BindableAction, Equatable {
        case addManualButtonTapped
        case alert(PresentationAction<Action>)
        case binding(BindingAction<AddressBook.State>)
        case contactStoreSuccess
        case deleteId(String)
        case deleteIdConfirmed
        case dismissAddContactRequired
        case dismissDeleteContactRequired
        case editId(String)
        case fetchedABContacts(AddressBookContacts, Bool)
        case fetchABContactsRequested
        case onAppear
        case checkDuplicates
        case saveButtonTapped
        case scanButtonTapped
        case walletAccountTapped(WalletAccount)
    }

    public init() { }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isValidForm = false
                state.deleteIdToConfirm = nil
                state.nameAlreadyExists = false
                state.addressAlreadyExists = false
                if let editId = state.editId {
                    return .concatenate(
                        .send(.editId(editId)),
                        .send(.fetchABContactsRequested)
                    )
                }
                return .send(.fetchABContactsRequested)

            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .addManualButtonTapped:
                state.address = ""
                state.name = ""
                state.isValidForm = false
                state.isAddressFocused = true
                return .none

            case .checkDuplicates:
                state.nameAlreadyExists = false
                state.addressAlreadyExists = false
                for contact in state.addressBookContacts.contacts {
                    if contact.name == state.name && state.name != state.originalName {
                        state.nameAlreadyExists = true
                    }
                    if contact.id == state.address && state.address != state.originalAddress {
                        state.addressAlreadyExists = true
                    }
                }
                return .none
                
            case .scanButtonTapped:
                return .none

            case .binding:
                state.isValidZcashAddress = derivationTool.isZcashAddress(state.address, zcashSDKEnvironment.network.networkType)
                state.isValidForm = !state.name.isEmpty && state.isValidZcashAddress
                return .send(.checkDuplicates)

            case .deleteId(let id):
                state.deleteIdToConfirm = id
                state.alert = AlertState.confirmDelete()
                return .none

            case .deleteIdConfirmed:
                state.alert = nil
                guard let deleteIdToConfirm = state.deleteIdToConfirm, let account = state.zashiWalletAccount else {
                    return .none
                }

                let contact = state.addressBookContacts.contacts.first {
                    $0.id == deleteIdToConfirm
                }
                if let contact {
                    do {
                        let result = try addressBook.deleteContact(account.account, contact)
                        let abContacts = result.contacts
                        if result.remoteStoreResult == .failure {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                        return .concatenate(
                            .send(.fetchedABContacts(abContacts, false)),
                            .send(.dismissDeleteContactRequired)
                        )
                    } catch {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                    }
                }
                return .none
                
            case .walletAccountTapped:
                return .none
                
            case .editId(let id):
                guard !state.isInSelectMode else {
                    return .none
                }
                
                let record = state.addressBookContacts.contacts.first {
                    $0.id == id
                }
                guard let record else {
                    return .none
                }
                state.address = record.id
                state.name = record.name
                state.originalAddress = state.address
                state.originalName = state.name
                state.isValidForm = true
                state.isNameFocused = true
                state.isValidZcashAddress = derivationTool.isZcashAddress(state.address, zcashSDKEnvironment.network.networkType)
                return .none

            case .saveButtonTapped:
                guard let account = state.zashiWalletAccount else {
                    return .none
                }
                do {
                    let result = try addressBook.storeContact(account.account, Contact(address: state.address, name: state.name))
                    let abContacts = result.contacts
                    if result.remoteStoreResult == .failure {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                    }
                    return .concatenate(
                        .send(.fetchedABContacts(abContacts, false)),
                        .send(.contactStoreSuccess),
                        .send(.dismissAddContactRequired)
                    )
                } catch {
                    // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                }
                return .none

            case .contactStoreSuccess:
                state.address = ""
                state.name = ""
                state.isAddressFocused = false
                state.isNameFocused = false
                return .none

            case .fetchABContactsRequested:
                guard let account = state.zashiWalletAccount else {
                    return .none
                }
                do {
                    let result = try addressBook.allLocalContacts(account.account)
                    let abContacts = result.contacts
                    if result.remoteStoreResult == .failure {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                    }
                    return .send(.fetchedABContacts(abContacts, true))
                } catch {
                    // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                }
                return .none

            case let .fetchedABContacts(abContacts, requestToSync):
                guard let account = state.zashiWalletAccount else {
                    return .none
                }
                state.$addressBookContacts.withLock { $0 = abContacts }
                if requestToSync {
                    return .run { send in
                        do {
                            let result = try await addressBook.syncContacts(account.account, abContacts)
                            let syncedContacts = result.contacts
                            if result.remoteStoreResult == .failure {
                                // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                            }
                            await send(.fetchedABContacts(syncedContacts, false))
                        } catch {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                    }
                }
                return .none
                
            case .dismissAddContactRequired:
                return .none

            case .dismissDeleteContactRequired:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == AddressBook.Action {
    public static func confirmDelete() -> AlertState {
        AlertState {
            TextState(L10n.AddressBook.Alert.title)
        } actions: {
            ButtonState(role: .destructive, action: .deleteIdConfirmed) {
                TextState(L10n.General.confirm)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.cancel)
            }
        } message: {
            TextState(L10n.AddressBook.Alert.message)
        }
    }
}
