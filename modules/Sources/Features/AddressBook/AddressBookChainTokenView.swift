//
//  AddressBookChainTokenView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2025.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Generated

public struct AddressBookChainTokenView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>

    @FocusState public var isChainFocused: Bool
    @FocusState public var isTokenFocused: Bool
    
    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ZashiTextField(
                    addressFont: true,
                    text: $store.chain,
                    placeholder: L10n.AddressBook.NewContact.addressPlaceholder,
                    title: L10n.AddressBook.NewContact.address,
                    error: store.invalidAddressErrorText
                )
                .padding(.top, 20)
                .focused($isChainFocused)

                ZashiTextField(
                    text: $store.token,
                    placeholder: L10n.AddressBook.NewContact.namePlaceholder,
                    title: L10n.AddressBook.NewContact.name,
                    error: store.invalidNameErrorText
                )
                .padding(.vertical, 20)
                .focused($isTokenFocused)

                Spacer()
                
                ZashiButton(L10n.General.save) {
                    
                }
                //.disabled(store.isSaveButtonDisabled)
                .padding(.bottom, store.editId != nil ? 0 : 24)

                if store.editId != nil {
                    ZashiButton(L10n.General.delete, type: .destructive1) {
                        store.send(.deleteId(store.address))
                    }
                    .padding(.bottom, 24)
                }
            }
            .screenHorizontalPadding()
            .onAppear {
                isChainFocused = store.isChainFocused
                if !isChainFocused {
                    isTokenFocused = store.isTokenFocused
                }
                store.send(.onAppear)
            }
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
        }
        .applyScreenBackground()
        .zashiBack()
//        .screenTitle(
//            store.editId != nil
//            ? L10n.AddressBook.savedAddress
//            : L10n.AddressBook.NewContact.title
//        )
    }
}

#Preview {
    AddressBookContactView(store: AddressBook.initial)
}
