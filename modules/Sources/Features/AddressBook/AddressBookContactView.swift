//
//  AddressBookContactView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Generated

public struct AddressBookContactView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>
    let isInEditMode: Bool

    @FocusState public var isAddressFocused: Bool
    @FocusState public var isNameFocused: Bool
    
    public init(store: StoreOf<AddressBook>, isInEditMode: Bool = false) {
        self.store = store
        self.isInEditMode = isInEditMode
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ZashiTextField(
                    text: $store.address,
                    placeholder: L10n.AddressBook.NewContact.addressPlaceholder,
                    title: L10n.AddressBook.NewContact.address,
                    error: store.invalidAddressErrorText
                )
                .padding(.top, 20)
                .focused($isAddressFocused)

                ZashiTextField(
                    text: $store.name,
                    placeholder: L10n.AddressBook.NewContact.namePlaceholder,
                    title: L10n.AddressBook.NewContact.name,
                    error: store.invalidNameErrorText
                )
                .padding(.vertical, 20)
                .focused($isNameFocused)

                Spacer()
                
                ZashiButton(L10n.General.save) {
                    store.send(.saveButtonTapped)
                }
                .disabled(store.isSaveButtonDisabled)
                .padding(.bottom, isInEditMode ? 0 : 24)

                if isInEditMode {
                    ZashiButton(L10n.General.delete, type: .destructive1) {
                        store.send(.deleteId(store.address))
                    }
                    .padding(.bottom, 24)
                }
            }
            .screenHorizontalPadding()
            .onAppear {
                isAddressFocused = store.isAddressFocused
                if !isAddressFocused {
                    isNameFocused = store.isNameFocused
                }
            }
        }
        .applyScreenBackground()
        .zashiBack()
        .screenTitle(
            isInEditMode
            ? L10n.AddressBook.savedAddress
            : L10n.AddressBook.NewContact.title
        )
    }
}

#Preview {
    AddressBookContactView(store: AddressBook.initial)
}
