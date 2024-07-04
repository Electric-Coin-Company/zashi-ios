//
//  AddressBookView.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Scan

public struct AddressBookView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>
    
    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                if store.records.isEmpty {
                    Text("No items")
                        .font(.custom(FontFamily.Inter.bold.name, size: 13))
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.shade97.color)
                        .listRowSeparator(.hidden)
                        .padding(.top, 30)
                    
                    Spacer()
                } else {
                    List {
                        ForEach(store.records, id: \.self) { record in
                            HStack {
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .foregroundColor(Asset.Colors.shade30.color)
                                    .padding(.trailing, 10)
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(record.name)
                                        .font(.custom(FontFamily.Inter.medium.name, size: 16))
                                        .foregroundColor(Asset.Colors.primary.color)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(record.id)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 13))
                                        .truncationMode(.middle)
                                        .lineLimit(1)
                                        .foregroundColor(Asset.Colors.shade47.color)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Asset.Colors.shade97.color)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 30)
                            .padding(.horizontal, 35)
                            .swipeActions(allowsFullSwipe: false) {
                                Button {
                                    store.send(.onEditId(record.id))
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.indigo)
                                
                                Button(role: .destructive) {
                                    store.send(.onDeleteId(record.id))
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 1)
                    .background(Asset.Colors.shade97.color)
                    .listStyle(.plain)
                }
            }
            .onAppear { store.send(.onAppear) }
            .zashiBack()
            .zashiTitle {
                Text("Address Book".uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
            .navigationBarItems(trailing: settingsButton(store))
            .navigationBarTitleDisplayMode(.inline)
            .applyScreenBackground()
            .sheet(item: $store.recordToBeAdded) { _ in
                AddressBookNewRecordView(store: store)
            }
            .navigationLinkEmpty(
                isActive: $store.scanViewBinding,
                destination: {
                    ScanView(
                        store: store.scope(
                            state: \.scanState,
                            action: \.scan
                        )
                    )
                }
            )
        }
    }
    
    func settingsButton(_ store: StoreOf<AddressBook>) -> some View {
        WithPerceptionTracking {
            Menu {
                Button {
                    store.send(.scanButtonTapped)
                } label: {
                    HStack {
                        Text("Scan address QR")
                        Image(systemName: "qrcode")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .tint(Asset.Colors.primary.color)
                    }
                }
                Button {
                    store.send(.addManualButtonTapped)
                } label: {
                    HStack {
                        Text("Manual Entry")
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .tint(Asset.Colors.primary.color)
                    }
                }
            } label: {
                Text("Add")
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                    .foregroundColor(Asset.Colors.shade30.color)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    AddressBookView(store: AddressBook.initial)
}

// MARK: - Store

extension AddressBook {
    public static var initial = StoreOf<AddressBook>(
        initialState: .initial
    ) {
        AddressBook()
    }
}

// MARK: - Placeholders

extension AddressBook.State {
    public static let initial = AddressBook.State(scanState: .initial)
}
