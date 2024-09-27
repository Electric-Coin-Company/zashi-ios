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
import Scan
import AudioServices

@Reducer
public struct AddressBook {
    enum Constants {
        static let maxNameLength = 32
    }
    
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case add
        }
        
        public var address = ""
        public var addressAlreadyExists = false
        @Shared(.inMemory(.addressBookRecords)) public var addressBookRecords: IdentifiedArrayOf<ABRecord> = []
        @Presents public var alert: AlertState<Action>?
        public var deleteIdToConfirm: String?
        public var destination: Destination?
        public var isAddressFocused = false
        public var isInEditMode = false
        public var isInSelectMode = false
        public var isNameFocused = false
        public var isValidForm = false
        public var isValidZcashAddress = false
        public var name = ""
        public var nameAlreadyExists = false
        public var originalAddress = ""
        public var originalName = ""
        public var scanState: Scan.State
        public var scanViewBinding = false

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

        public init(
            scanState: Scan.State
        ) {
            self.scanState = scanState
        }
    }

    public enum Action: BindableAction, Equatable {
        case addManualButtonTapped
        case alert(PresentationAction<Action>)
        case binding(BindingAction<AddressBook.State>)
        case contactStoreSuccess
        case deleteId(String)
        case deleteIdConfirmed
        case editId(String)
        case fetchedABRecords(IdentifiedArrayOf<ABRecord>)
        case fetchABRecordsRequested
        case onAppear
        case checkDuplicates
        case saveButtonTapped
        case scan(Scan.Action)
        case scanButtonTapped
        case updateDestination(AddressBook.State.Destination?)
    }

    public init() { }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.originalName = ""
                state.originalAddress = ""
                state.isInEditMode = false
                state.isValidForm = false
                state.isValidZcashAddress = false
                state.deleteIdToConfirm = nil
                state.name = ""
                state.address = ""
                state.nameAlreadyExists = false
                state.addressAlreadyExists = false
                state.isAddressFocused = false
                state.isNameFocused = false
                return .send(.fetchABRecordsRequested)

            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .addManualButtonTapped:
                state.address = ""
                state.name = ""
                state.isValidForm = false
                state.isInEditMode = false
                state.isAddressFocused = true
                return .send(.updateDestination(.add))

            case .checkDuplicates:
                state.nameAlreadyExists = false
                state.addressAlreadyExists = false
                for record in state.addressBookRecords {
                    if record.name == state.name && state.name != state.originalName {
                        state.nameAlreadyExists = true
                    }
                    if record.id == state.address && state.address != state.originalAddress {
                        state.addressAlreadyExists = true
                    }
                }
                return .none
                
            case .scanButtonTapped:
                state.scanViewBinding = true
                return .none

            case .scan(.found(let address)):
                state.address = address.data
                state.name = ""
                audioServices.systemSoundVibrate()
                state.scanViewBinding = false
                state.isNameFocused = true
                return .send(.updateDestination(.add))

            case .scan(.cancelPressed):
                state.scanViewBinding = false
                return .none

            case .scan:
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
                guard let deleteIdToConfirm = state.deleteIdToConfirm else {
                    return .none
                }
                
                let record = state.addressBookRecords.first {
                    $0.id == deleteIdToConfirm
                }
                if let record {
                    return .run { send in
                        do {
                            let contacts = try await addressBook.deleteContact(record)
                            await send(.fetchedABRecords(contacts))
                            await send(.updateDestination(nil))
                        } catch {
                            // TODO: FIXME
                        }
                    }
                }
                return .none

            case .editId(let id):
                guard !state.isInSelectMode else {
                    return .none
                }
                
                let record = state.addressBookRecords.first {
                    $0.id == id
                }
                guard let record else {
                    return .none
                }
                state.address = record.id
                state.name = record.name
                state.originalAddress = state.address
                state.originalName = state.name
                state.isInEditMode = true
                state.isValidForm = true
                state.isNameFocused = true
                state.isValidZcashAddress = derivationTool.isZcashAddress(state.address, zcashSDKEnvironment.network.networkType)
                return .send(.updateDestination(.add))

            case .saveButtonTapped:
                let name = state.name.isEmpty ? "testName" : state.name
                let address = state.address.isEmpty ? "testAddress" : state.address
                return .run { send in
                    do {
                        let contacts = try await addressBook.storeContact(ABRecord(address: address, name: name))
                        await send(.fetchedABRecords(contacts))
                        await send(.contactStoreSuccess)
                    } catch {
                        // TODO: FIXME
                        print("__LD saveButtonTapped Error: \(error.localizedDescription)")
                        await send(.updateDestination(nil))
                    }
                }

            case .contactStoreSuccess:
                state.address = ""
                state.name = ""
                state.isAddressFocused = false
                state.isNameFocused = false
                return .send(.updateDestination(nil))

            case .fetchABRecordsRequested:
                return .run { send in
                    do {
                        let records = try await addressBook.allContacts()
                        await send(.fetchedABRecords(records))
                        print("__LD updateRecords success")
                    } catch {
                        print("__LD updateRecords Error: \(error.localizedDescription)")
                        // TODO: FIXME
                    }
                }
                
            case .fetchedABRecords(let records):
                state.addressBookRecords = records
                return .none

            case .updateDestination(let destination):
                state.destination = destination
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
