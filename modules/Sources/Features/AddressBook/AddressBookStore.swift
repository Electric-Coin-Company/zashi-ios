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
    @ObservableState
    public struct State: Equatable {
        public var address: String = ""
        public var isValidForm: Bool = false
        public var name: String = ""
        public var records: IdentifiedArrayOf<ABRecord>
        public var recordToBeAdded: ABRecord?
        public var scanState: Scan.State
        public var scanViewBinding: Bool = false

        public init(
            records: IdentifiedArrayOf<ABRecord> = [],
            recordToBeAdded: ABRecord? = nil,
            scanState: Scan.State
        ) {
            self.records = records
            self.recordToBeAdded = recordToBeAdded
            self.scanState = scanState
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case addManualButtonTapped
        case binding(BindingAction<AddressBook.State>)
        case onAppear
        case onDelete(IndexSet)
        case onDeleteId(String)
        case onEditId(String)
        case saveButtonTapped
        case scan(Scan.Action)
        case scanButtonTapped
        case updateRecords
    }

    public init() { }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.scanState, action: /Action.scan) {
            Scan()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.updateRecords)

            case .addManualButtonTapped:
                state.recordToBeAdded = ABRecord(address: "", name: "")
                return .none

            case .scanButtonTapped:
                state.scanViewBinding = true
                return .none
                
            case .scan(.found(let address)):
                state.address = address.data
                state.recordToBeAdded = ABRecord(address: address.data, name: "")
                audioServices.systemSoundVibrate()
                state.scanViewBinding = false
                return .none

            case .scan(.cancelPressed):
                state.scanViewBinding = false
                return .none
                
            case .scan:
                return .none
                
            case .binding:
                state.isValidForm = !state.name.isEmpty && derivationTool.isZcashAddress(state.address, zcashSDKEnvironment.network.networkType)
                return .none

            case .onDelete(let indexSet):
                for index in indexSet {
                    if index < state.records.count {
                        addressBook.deleteRecipient(state.records[index])
                    }
                }
                return .send(.updateRecords)

            case .onDeleteId(let id):
                let record = state.records.first {
                    $0.id == id
                }
                if let record {
                    addressBook.deleteRecipient(record)
                    return .send(.updateRecords)
                }
                return .none

            case .onEditId(let id):
                let record = state.records.first {
                    $0.id == id
                }
                if let record {
                    state.address = record.id
                    state.name = record.name
                    state.recordToBeAdded = record
                }
                return .none

            case .saveButtonTapped:
                addressBook.storeRecipient(ABRecord(address: state.address, name: state.name))
                state.address = ""
                state.name = ""
                state.recordToBeAdded = nil
                return .send(.updateRecords)

            case .updateRecords:
                state.records = addressBook.all()
                return .none
            }
        }
    }
}
