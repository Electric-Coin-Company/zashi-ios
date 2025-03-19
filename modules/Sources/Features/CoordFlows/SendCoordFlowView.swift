//
//  RequestZecCoordFlowView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2023-03-18.
//

import SwiftUI
import ComposableArchitecture

import UIComponents
import ZecKeyboard
import Generated

// Path
import AddressBook
import Scan
import SendForm

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
                case let .scan(store):
                    ScanView(store: store)
                }
            }
            .navigationBarHidden(!store.path.isEmpty)
        }
        .padding(.horizontal, 4)
        .applyScreenBackground()
        .zashiBack()
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
