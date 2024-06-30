//
//  AddressBookNewRecordView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import SwiftUI
import ComposableArchitecture
import UIComponents
import Generated

public struct AddressBookNewRecordView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>
    
    @FocusState public var isAddressFocused: Bool
    @FocusState public var isNameFocused: Bool

    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("New Address Record".uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                    .padding(.top, 15)
                
                ZashiTextField(
                    text: $store.address,
                    placeholder: "Zcash address",
                    title: "Address:"
                )
                .focused($isAddressFocused)
                .padding(.top, 40)
                .submitLabel(.next)
                .onSubmit {
                    isNameFocused = true
                }

                ZashiTextField(
                    text: $store.name,
                    placeholder: "Any name or nickname",
                    title: "Contact name:"
                )
                .focused($isNameFocused)
                .padding(.vertical, 20)
                .submitLabel(.return)
                .onSubmit {
                    if store.isValidForm {
                        store.send(.saveButtonTapped)
                    }
                }

                Button("Save".uppercased()) {
                    store.send(.saveButtonTapped)
                }
                .zcashStyle()
                .padding(.vertical, 20)
                .padding(.horizontal, 50)
                .disabled(!store.isValidForm)
                
                Spacer()
            }
            .padding(.horizontal, 35)
            .onAppear {
                if let id = store.recordToBeAdded?.id, id == "" {
                    isAddressFocused = true
                } else {
                    isNameFocused = true
                }
            }
        }
        .applyScreenBackground()
    }
}

#Preview {
    AddressBookNewRecordView(store: AddressBook.initial)
}
