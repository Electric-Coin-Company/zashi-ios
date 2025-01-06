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
    @Environment(\.colorScheme) private var colorScheme
    @Perception.Bindable var store: StoreOf<AddressBook>

    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                if store.isInSelectMode && store.walletAccounts.count > 1 {
                    contactsList()
                } else {
                    if store.addressBookContacts.contacts.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 40) {
                            emptyComposition()
                            
                            Text(L10n.AddressBook.empty)
                                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .screenHorizontalPadding()
                    } else {
                        contactsList()
                    }
                }

                Spacer()

                addContactButton(store)
            }
            .onAppear { store.send(.onAppear) }
            .zashiBack()
            .screenTitle(
                store.isInSelectMode && (!store.addressBookContacts.contacts.isEmpty || store.walletAccounts.count > 1)
                ? L10n.AddressBook.selectRecipient
                : L10n.AddressBook.title
            )
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
                .zForegroundColor(Design.Btns.Tertiary.fg)
                .background {
                    Circle()
                        .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                        .frame(width: 72, height: 72)
                }

            ZcashSymbol()
                .frame(width: 24, height: 24)
                .zForegroundColor(Design.Surfaces.bgPrimary)
                .background {
                    Circle()
                        .fill(Design.Surfaces.brandBg.color(colorScheme))
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                .frame(width: 36, height: 36)
                        }
                }
                .offset(x: 30, y: 30)
                .shadow(color: .black.opacity(0.02), radius: 0.66667, x: 0, y: 1.33333)
                .shadow(color: .black.opacity(0.08), radius: 1.33333, x: 0, y: 1.33333)
        }
    }
    
    @ViewBuilder func contactsList() -> some View {
        List {
            if store.walletAccounts.count > 1 && store.isInSelectMode {
                Text(L10n.Accounts.AddressBook.your)
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    .screenHorizontalPadding()
                    .listBackground()

                ForEach(store.walletAccounts, id: \.self) { walletAccount in
                    VStack {
                        walletAcoountView(
                            icon: walletAccount.vendor.icon(),
                            title: walletAccount.vendor.name(),
                            address: walletAccount.unifiedAddress ?? L10n.Receive.Error.cantExtractUnifiedAddress
                        ) {
                            store.send(.walletAccountTapped(walletAccount))
                        }
                        
                        if let last = store.walletAccounts.last, last != walletAccount {
                            Design.Surfaces.divider.color(colorScheme)
                                .frame(height: 1)
                                .padding(.top, 12)
                                .padding(.horizontal, 4)
                        }
                    }
                    .listBackground()
                }
                
                if store.addressBookContacts.contacts.isEmpty {
                    VStack(spacing: 40) {
                        emptyComposition()
                        
                        Text(L10n.AddressBook.empty)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listBackground()
                    .screenHorizontalPadding()
                    .padding(.bottom, 40)
                    .padding(.top, 70)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Design.Surfaces.strokeSecondary.color(colorScheme), style: StrokeStyle(lineWidth: 2.0, dash: [8, 6]))
                    }
                    .padding(.top, 24)
                    .screenHorizontalPadding()
                } else {
                    Text(L10n.Accounts.AddressBook.contacts)
                        .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                        .screenHorizontalPadding()
                        .listBackground()
                }
            }

            ForEach(store.addressBookContacts.contacts, id: \.self) { record in
                VStack {
                    ContactView(
                        iconText: record.name.initials,
                        title: record.name,
                        desc: record.id.trailingZip316
                    ) {
                        store.send(.editId(record.id))
                    }

                    if let last = store.addressBookContacts.contacts.last, last != record {
                        Design.Surfaces.divider.color(colorScheme)
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
    
    @ViewBuilder func walletAccountsList() -> some View {
        List {
            ForEach(store.walletAccounts, id: \.self) { walletAccount in
                VStack {
                    walletAcoountView(
                        icon: walletAccount.vendor.icon(),
                        title: walletAccount.vendor.name(),
                        address: walletAccount.unifiedAddress ?? L10n.Receive.Error.cantExtractUnifiedAddress
                    ) {
                        store.send(.walletAccountTapped(walletAccount))
                    }
                    
                    if let last = store.walletAccounts.last, last != walletAccount {
                        Design.Surfaces.divider.color(colorScheme)
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
    
    @ViewBuilder func walletAcoountView(
        icon: Image,
        title: String,
        address: String,
        selected: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        WithPerceptionTracking {
            Button {
                action?()
            } label: {
                HStack(spacing: 0) {
                    icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.bgAlt.color(colorScheme))
                        }
                        .padding(.trailing, 12)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .zFont(.semiBold, size: 14, style: Design.Text.primary)
                        
                        Text(address.zip316)
                            .zFont(addressFont: true, size: 12, style: Design.Text.tertiary)
                    }
                    
                    Spacer()
                    
                    Asset.Assets.chevronRight.image
                        .zImage(size: 20, style: Design.Text.tertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    if selected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    }
                }
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

// MARK: - Bindings

extension StoreOf<AddressBook> {
    func bindingFor(_ destination: AddressBook.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}
