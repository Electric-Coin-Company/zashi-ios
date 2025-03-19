//
//  SendCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-18.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import Generated

// Path
import AddressBook
import PartialProposalError
import Scan
import SendConfirmation
import SendForm
import TransactionDetails

public struct SendCoordFlowView: View {
    @Environment(\.colorScheme) var colorScheme

    @Perception.Bindable var store: StoreOf<SendCoordFlow>
    let tokenName: String

    public init(store: StoreOf<SendCoordFlow>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                SendFormView(
                    store:
                        store.scope(
                            state: \.sendFormState,
                            action: \.sendForm
                        ),
                    tokenName: tokenName
                )
                .navigationBarHidden(true)
            } destination: { store in
                switch store.case {
                case let .addressBook(store):
                    AddressBookView(store: store)
                case let .addressBookContact(store):
                    AddressBookContactView(store: store)
                case let .preSendingFailure(store):
                    PreSendingFailureView(store: store, tokenName: tokenName)
                case let .scan(store):
                    ScanView(store: store)
                case let .sendConfirmation(store):
                    SendConfirmationView(store: store, tokenName: tokenName)
                case let .sending(store):
                    SendingView(store: store, tokenName: tokenName)
                case let .sendResultFailure(store):
                    FailureView(store: store, tokenName: tokenName)
                case let .sendResultPartial(store):
                    PartialProposalErrorView(store: store)
                case let .sendResultResubmission(store):
                    ResubmissionView(store: store, tokenName: tokenName)
                case let .sendResultSuccess(store):
                    SuccessView(store: store, tokenName: tokenName)
                case let .transactionDetails(store):
                    TransactionDetailsView(store: store, tokenName: tokenName)
                }
            }
            .navigationBarHidden(!store.path.isEmpty)
        }
        .applyScreenBackground()
        .zashiBack { store.send(.dismissRequired) }
        .screenTitle(L10n.General.send)
    }
}

#Preview {
    NavigationView {
        SendCoordFlowView(store: SendCoordFlow.placeholder, tokenName: "ZEC")
    }
}

// MARK: - Placeholders

extension SendCoordFlow.State {
    public static let initial = SendCoordFlow.State()
}

extension SendCoordFlow {
    public static let placeholder = StoreOf<SendCoordFlow>(
        initialState: .initial
    ) {
        SendCoordFlow()
    }
}
