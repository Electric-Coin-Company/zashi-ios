//
//  AddressChainTokenView.swift
//  modules
//
//  Created by Lukáš Korba on 2025-05-23.
//

import SwiftUI
import ComposableArchitecture
import Generated

import UIComponents
import BalanceFormatter
import WalletBalances

public struct AddressChainTokenView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private enum InputID: Hashable {
        case addressBookHint
    }
    
    @State private var keyboardVisible: Bool = false
    
    @FocusState private var isAddressFocused
    
    @Perception.Bindable var store: StoreOf<SwapAndPay>
    let tokenName: String
    
    public init(store: StoreOf<SwapAndPay>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: \.walletBalances
                    ),
                    tokenName: tokenName,
                    couldBeHidden: true
                )
                .frame(height: 150)
                
                ZashiTextField(
                    addressFont: true,
                    text: $store.address,
                    placeholder: L10n.SwapAndPay.enterAddress,
                    title: L10n.Send.to,
                    accessoryView:
                        HStack(spacing: 4) {
                            WithPerceptionTracking {
                                fieldButton(
                                    icon: store.isNotAddressInAddressBook
                                    ? Asset.Assets.Icons.userPlus.image
                                    : Asset.Assets.Icons.user.image
                                ) {
                                    if store.isNotAddressInAddressBook {
                                        //store.send(.addNewContactTapped(store.address))
                                    } else {
                                        //store.send(.addressBookTapped)
                                    }
                                }
                                
                                fieldButton(icon: Asset.Assets.Icons.qr.image) {
                                    //store.send(.scanTapped)
                                }
                            }
                        }
                        .frame(height: 20)
                        .offset(x: 8)
                )
                .id(InputID.addressBookHint)
                .keyboardType(.alphabet)
                .focused($isAddressFocused)
                .padding(.bottom, 20)
                .anchorPreference(
                    key: UnknownAddressPreferenceKey.self,
                    value: .bounds
                ) { $0 }
                
                assetSelector()

                Spacer()
                
                ZashiButton(L10n.General.next) {
                    store.send(.nextTapped)
                }
                .padding(.bottom, 24)
            }
            .screenHorizontalPadding()
            .onAppear {
                store.send(.onAppear)
                observeKeyboardNotifications()
            }
            .applyScreenBackground()
            .zashiBack(hidden: store.isPopToRootBack) { store.send(.dismissRequired) }
            .zashiBackV2(hidden: !store.isPopToRootBack) { store.send(.dismissRequired) }
            .sheet(isPresented: $store.balancesBinding) {
                if #available(iOS 16.4, *) {
                    balancesContent()
                        .applyScreenBackground()
                        .presentationDetents([.height(store.sheetHeight)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(Design.Radius._4xl)
                } else {
                    balancesContent()
                        .applyScreenBackground()
                        .presentationDetents([.height(store.sheetHeight)])
                        .presentationDragIndicator(.visible)
                }
            }
            .popover(isPresented: $store.assetSelectBinding) {
                assetContent(colorScheme)
                    .padding(.horizontal, 4)
                    .applyScreenBackground()
            }
            .overlayPreferenceValue(UnknownAddressPreferenceKey.self) { preferences in
                if isAddressFocused && store.isAddressBookHintVisible {
                    GeometryReader { geometry in
                        preferences.map {
                            HStack(alignment: .top, spacing: 0) {
                                Asset.Assets.Icons.userPlus.image
                                    .zImage(size: 20, style: Design.HintTooltips.titleText)
                                    .padding(.trailing, 12)
                                
                                Text(L10n.Send.addressNotInBook)
                                    .zFont(.medium, size: 14, style: Design.HintTooltips.titleText)
                                    .padding(.top, 2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 40)
                            .background {
                                RoundedRectangle(cornerRadius: Design.Radius._md)
                                    .fill(Design.HintTooltips.surfacePrimary.color(colorScheme))
                            }
                            .frame(width: geometry.size.width - 48)
                            .offset(x: 24, y: geometry[$0].minY + geometry[$0].height - 16)
                        }
                    }
                }
            }
            .overlay {
                if keyboardVisible {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Asset.Colors.primary.color
                            .frame(height: 1)
                            .opacity(0.1)
                        
                        HStack(alignment: .center) {
                            Spacer()
                            
                            Button {
                                isAddressFocused = false
                            } label: {
                                Text(L10n.General.done.uppercased())
                                    .zFont(.regular, size: 14, style: Design.Text.primary)
                            }
                            .padding(.bottom, 4)
                        }
                        .applyScreenBackground()
                        .padding(.horizontal, 20)
                        .frame(height: keyboardVisible ? 38 : 0)
                        .frame(maxWidth: .infinity)
                        .opacity(keyboardVisible ? 1 : 0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func assetSelector() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.SwapAndPay.selectToken)
                .lineLimit(1)
                .font(.custom(FontFamily.Inter.medium.name, size: 14))
                .zForegroundColor(Design.Inputs.Filled.label)
                .padding(.bottom, 6)
            
            Button {
                store.send(.assetSelectRequested)
            } label: {
                HStack(spacing: 0) {
                    if let selectedAsset = store.selectedAsset {
                        
                    } else {
                        Text(L10n.SwapAndPay.select)
                            .font(.custom(FontFamily.Inter.regular.name, size: 16))
                            .foregroundColor(Design.Inputs.Default.text.color(colorScheme))
                    }
                    
                    Spacer()
                    
                    Asset.Assets.chevronDown.image
                        .zImage(size: 24, style: Design.Text.primary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Design.Radius._lg)
                    .fill(Design.Inputs.Default.bg.color(colorScheme))
            )
        }
    }
    
    private func fieldButton(icon: Image, _ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            icon
                .zImage(size: 20, style: Design.Inputs.Default.label)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: Design.Radius._md)
                .fill(Design.Btns.Secondary.bg.color(colorScheme))
                .overlay {
                    RoundedRectangle(cornerRadius: Design.Radius._md)
                        .stroke(Design.Btns.Secondary.border.color(colorScheme))
                }
        }
    }
    
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = true
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = false
            }
        }
    }
}

// MARK: Placeholders

extension SwapAndPay.State {
    public static var initial: Self {
        .init(
            walletBalancesState: .initial
        )
    }
}

extension StoreOf<SwapAndPay> {
    public static var placeholder: StoreOf<SwapAndPay> {
        StoreOf<SwapAndPay>(
            initialState: .initial
        ) {
            SwapAndPay()
        }
    }
}
