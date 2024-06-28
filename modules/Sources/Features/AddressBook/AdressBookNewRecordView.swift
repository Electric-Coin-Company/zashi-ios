//
//  AddressBookNewRecordView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import SwiftUI
import ComposableArchitecture
import UIComponents

public struct AddressBookNewRecordView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>
    
    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                Spacer()
                
                ZashiTextField(
                    text: $store.address,
                    placeholder: "Zcash address",
                    title: "Address:"
                )
                .padding(.top, 20)
                
                ZashiTextField(
                    text: $store.name,
                    placeholder: "Any name or nickname",
                    title: "Contact name:"
                )
                .padding(.vertical, 20)
                
                Button("Save".uppercased()) {
                    store.send(.saveButtonTapped)
                }
                .zcashStyle()
                .padding(.bottom, 20)
                .disabled(!store.isValidForm)
            }
            .padding(.horizontal, 35)
        }
        .applyScreenBackground()
    }
}

#Preview {
    AddressBookNewRecordView(store: AddressBook.initial)
}
