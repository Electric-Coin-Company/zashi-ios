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
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<AddressBook>

    @FocusState public var isAddressFocused: Bool
    @FocusState public var isNameFocused: Bool
    @FocusState public var isChainIdFocused: Bool

    public init(store: StoreOf<AddressBook>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ZashiTextField(
                    addressFont: true,
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
                .padding(.top, 20)
                .padding(.bottom, store.isSwapFlowActive ? 0 : 20)
                .focused($isNameFocused)

                if store.isSwapFlowActive {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(L10n.SwapAndPay.addressBookSelectChain)
                            .zFont(.medium, size: 14, style: Design.Dropdowns.Default.label)
                            .padding(.bottom, 6)
                        
                        Button {
                            store.send(.selectChainTapped)
                        } label: {
                            HStack(spacing: 0) {
                                if let selectedChain = store.selectedChain {
                                    selectedChain.chainIcon
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.trailing, 8)

                                    Text(selectedChain.chainName)
                                        .zFont(size: 16, style: Design.Dropdowns.Default.text)
                                } else {
                                    Text(L10n.SwapAndPay.addressBookSelect)
                                        .zFont(size: 16, style: Design.Dropdowns.Default.text)
                                }
                                
                                Spacer()
                                
                                Asset.Assets.chevronDown.image
                                    .zImage(size: 18, style: Design.Text.primary)
                            }
                            .padding(.vertical, store.selectedChain == nil ? 10 : 8)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius._lg)
                                    .fill(Design.Inputs.Default.bg.color(colorScheme))
                            )
                        }
                    }
                    .padding(.top, 20)
                    .focused($isChainIdFocused)
                }

                Spacer()
                
                ZashiButton(L10n.General.save) {
                    store.send(.saveButtonTapped)
                }
                .disabled(store.isSaveButtonDisabled)
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
                isAddressFocused = store.isAddressFocused
                if !isAddressFocused {
                    isNameFocused = store.isNameFocused
                }
                store.send(.onAppear)
            }
            .alert(
                store: store.scope(
                    state: \.$alert,
                    action: \.alert
                )
            )
            .popover(isPresented: $store.chainSelectBinding) {
                assetContent(colorScheme)
                    .padding(.horizontal, 4)
                    .applyScreenBackground()
            }
        }
        .applyScreenBackground()
        .zashiBack()
        .screenTitle(
            store.editId != nil
            ? L10n.AddressBook.savedAddress
            : L10n.SwapAndPay.addressBookNewContact
        )
    }
}

#Preview {
    AddressBookContactView(store: AddressBook.initial)
}
