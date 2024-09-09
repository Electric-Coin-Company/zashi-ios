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

extension String {
    var initials: String {
        var res = ""
        self.split(separator: " ").forEach {
            if let firstChar = $0.first, res.count < 2 {
                res.append(String(firstChar))
            }
        }

        return res
    }
}

public struct AddressBookView: View {
    @Perception.Bindable var store: StoreOf<AddressBook>

    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack() {
                if store.addressBookRecords.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 40) {
                        emptyComposition()
                        
                        Text(L10n.AddressBook.empty)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    }
                    .screenHorizontalPadding()
                } else {
                    if store.isInSelectMode {
                        HStack {
                            Text(L10n.AddressBook.selectRecipient)
                                .zFont(.semiBold, size: 18, style: Design.Text.primary)
                            
                            Spacer()
                        }
                        .padding(24)
                    }
                    
                    List {
                        ForEach(store.addressBookRecords, id: \.self) { record in
                            VStack {
                                ContactView(
                                    iconText: record.name.initials,
                                    title: record.name,
                                    desc: record.id
                                ) {
                                    store.send(.editId(record.id))
                                }

                                if let last = store.addressBookRecords.last, last != record {
                                    Design.Surfaces.divider.color
                                        .frame(height: 1)
                                        .padding(.top, 12)
                                        .padding(.horizontal, 4)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Asset.Colors.background.color)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .padding(.vertical, 1)
                    .background(Asset.Colors.background.color)
                    .listStyle(.plain)
                }
                
                Spacer()

                addContactButton(store)
            }
            .onAppear { store.send(.onAppear) }
            .zashiBack()
            .screenTitle(L10n.AddressBook.title)
            .navigationBarTitleDisplayMode(.inline)
            .applyScreenBackground()
            .navigationLinkEmpty(
                isActive: store.bindingFor(.add),
                destination: {
                    AddressBookContactView(store: store, isInEditMode: store.isInEditMode)
                }
            )
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
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
        }
    }

    func addContactButton(_ store: StoreOf<AddressBook>) -> some View {
        WithPerceptionTracking {
            Menu {
                Button {
                    store.send(.scanButtonTapped)
                } label: {
                    HStack {
                        Asset.Assets.Icons.qr.image
                            .zImage(size: 20, style: Design.Text.primary)

                        Text(L10n.AddressBook.scanAddress)
                    }
                }

                Button {
                    store.send(.addManualButtonTapped)
                } label: {
                    HStack {
                        Asset.Assets.Icons.pencil.image
                            .zImage(size: 20, style: Design.Text.primary)

                        Text(L10n.AddressBook.manualEntry)
                    }
                }
            } label: {
                ZashiButton(
                    L10n.AddressBook.addNewContact,
                    prefixView:
                        Asset.Assets.Icons.plus.image
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 20, height: 20)
                ) {
                    
                }
                .screenHorizontalPadding()
                .padding(.bottom, 24)
            }
        }
    }
    
    func emptyComposition() -> some View {
        ZStack {
            Asset.Assets.send.image
                .zImage(size: 32, style: Design.Btns.Tertiary.fg)
                .foregroundColor(Design.Btns.Tertiary.fg.color)
                .background {
                    Circle()
                        .fill(Design.Btns.Tertiary.bg.color)
                        .frame(width: 72, height: 72)
                }

            ZcashSymbol()
                .frame(width: 24, height: 24)
                .foregroundColor(Design.Surfaces.bgPrimary.color)
                .background {
                    Circle()
                        .fill(Design.Surfaces.brandBg.color)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.bgPrimary.color)
                                .frame(width: 36, height: 36)
                        }
                }
                .offset(x: 30, y: 30)
                .shadow(color: .black.opacity(0.02), radius: 0.66667, x: 0, y: 1.33333)
                .shadow(color: .black.opacity(0.08), radius: 1.33333, x: 0, y: 1.33333)
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

// MARK: - Bindings

extension StoreOf<AddressBook> {
    func bindingFor(_ destination: AddressBook.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}
