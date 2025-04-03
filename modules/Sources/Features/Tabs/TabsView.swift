//
//  TabsView.swift
//  Zashi
//
//  Created by Lukáš Korba on 09.10.2023.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AddressDetails
import Generated
import Receive
import BalanceBreakdown
import Home
import SendForm
import Settings
import UIComponents
import SendConfirmation
import CurrencyConversionSetup
import RequestZec
import ZecKeyboard
import AddressBook
import AddKeystoneHWWallet
import Scan
import TransactionsManager
import TransactionDetails

public struct TabsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let networkType: NetworkType
    @Perception.Bindable var store: StoreOf<Tabs>
    let tokenName: String
    @Namespace var tabsID
    @State var accountSwitchSheetHeight: CGFloat = .zero
    @State var moreSheetHeight: CGFloat = .zero

    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<Tabs>, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }

    public var body: some View {
        WithPerceptionTracking {
            //NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                HomeView(
                    store: self.store.scope(
                        state: \.homeState,
                        action: \.home
                    ),
                    tokenName: tokenName
                )
//                .navigationBarItems(
//                    leading:
//                        walletAccountSwitcher()
//                )
//                .navigationBarItems(
//                    trailing:
//                        HStack(spacing: 0) {
//                            if store.selectedTab != .receive {
//                                hideBalancesButton()
//                            }
//                            
//                            settingsButton()
//                        }
//                        //.animation(nil, value: store.selectedTab)
//                )
//            } destination: { store in
//                switch store.case {
//                case let .sendFlow(store):
//                    SendFormView(store: store, tokenName: tokenName)
//                case let .receive(store):
//                    ReceiveView(store: store, networkType: networkType)
//                case let .scan(store):
//                    ScanView(store: store)
//                case let .sendConfirmation(store):
//                    SendConfirmationView(store: store, tokenName: tokenName)
//                }
//            }
            .onAppear { store.send(.onAppear) }
            .navigationLinkEmpty(
                isActive: store.bindingFor(.settings),
                destination: {
                    SettingsView(store: store.settingsStore())
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingFor(.sendConfirmationKeystone),
                destination: {
                    SignWithKeystoneView(store: store.sendConfirmationStore(), tokenName: tokenName)
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingFor(.currencyConversionSetup),
                destination: {
                    CurrencyConversionSetupView(
                        store: store.currencyConversionSetupStore()
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingFor(.addressDetails),
                destination: {
                    AddressDetailsView(store: store.addressDetailsStore())
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStackAddKeystoneKWWallet(.addKeystoneHWWallet),
                destination: {
                    AddKeystoneHWWalletView(
                        store: store.addKeystoneHWWalletStore()
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackAddKeystoneKWWallet(.scan),
                        destination: {
                            ScanView(
                                store: store.scanStore()
                            )
                            .navigationLinkEmpty(
                                isActive: store.bindingForStackAddKeystoneKWWallet(.accountSelection),
                                destination: {
                                    AccountsSelectionView(
                                        store: store.addKeystoneHWWalletStore()
                                    )
                                }
                            )
                        }
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStackMaxPrivacy(.zecKeyboard),
                destination: {
                    ZecKeyboardView(
                        store: store.zecKeyboardStore(),
                        tokenName: tokenName
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackMaxPrivacy(.requestZec),
                        destination: {
                            RequestZecView(
                                store: store.requestZecStore(),
                                tokenName: tokenName
                            )
                            .navigationLinkEmpty(
                                isActive: store.bindingForStackMaxPrivacy(.requestZecSummary),
                                destination: {
                                    RequestZecSummaryView(
                                        store: store.requestZecStore(),
                                        tokenName: tokenName
                                    )
                                }
                            )
                        }
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStackLowPrivacy(.zecKeyboard),
                destination: {
                    ZecKeyboardView(
                        store: store.zecKeyboardStore(),
                        tokenName: tokenName
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackLowPrivacy(.requestZecSummary),
                        destination: {
                            RequestZecSummaryView(
                                store: store.requestZecStore(),
                                tokenName: tokenName
                            )
                        }
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStackTransactions(.manager),
                destination: {
                    TransactionsManagerView(
                        store: store.transactionsManagerStore(),
                        tokenName: tokenName
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackTransactions(.details),
                        destination: {
                            TransactionDetailsView(
                                store: store.transactionDetailsStore(),
                                tokenName: tokenName
                            )
                            .navigationLinkEmpty(
                                isActive: store.bindingForStackTransactions(.addressBook),
                                destination: {
                                    AddressBookContactView(store: store.addressBookStore())
                                }
                            )
                        }
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: store.bindingForStackTransactionsHP(.details),
                destination: {
                    TransactionDetailsView(
                        store: store.transactionDetailsStore(),
                        tokenName: tokenName
                    )
                    .navigationLinkEmpty(
                        isActive: store.bindingForStackTransactionsHP(.addressBook),
                        destination: {
                            AddressBookContactView(store: store.addressBookStore())
                        }
                    )
                }
            )
            //..walletstatusPanel()
            .sheet(isPresented: $store.isInAppBrowserOn) {
                if let urlStr = store.inAppBrowserURL, let url = URL(string: urlStr) {
                    InAppBrowserView(url: url)
                }
            }
            .sheet(isPresented: $store.accountSwitchRequest) {
                accountSwitchContent()
            }
            .sheet(isPresented: $store.moreRequest) {
                moreContent()
            }
            .sheet(isPresented: $store.selectTextRequest) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        
                        Button {
                            store.send(.dismissSelectTextEditor)
                        } label: {
                            Asset.Assets.buttonCloseX.image
                                .zImage(size: 24, style: Design.Btns.Tertiary.fg)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                                }
                        }
                    }
                    
                    TextEditor(text: $store.textToSelect)
                        .colorBackground(Asset.Colors.background.color)
                        .background(Asset.Colors.background.color)
                        .zFont(size: 14, style: Design.Text.primary)
                }
                .padding()
                .applyScreenBackground()
            }
            .overlayPreferenceValue(ExchangeRateStaleTooltipPreferenceKey.self) { preferences in
                WithPerceptionTracking {
                    if store.isRateTooltipEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                Tooltip(
                                    title: L10n.Tooltip.ExchangeRate.title,
                                    desc: L10n.Tooltip.ExchangeRate.desc
                                ) {
                                    store.send(.rateTooltipTapped)
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
                            }
                        }
                    }
                }
            }
            .overlayPreferenceValue(ExchangeRateFeaturePreferenceKey.self) { preferences in
                WithPerceptionTracking {
                    if store.isRateEducationEnabled && store.selectedTab != .receive {
                        GeometryReader { geometry in
                            preferences.map {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .top, spacing: 0) {
                                        Asset.Assets.Icons.coinsSwap.image
                                            .zImage(size: 20, style: Design.Text.primary)
                                            .padding(10)
                                            .background {
                                                Circle()
                                                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                                            }
                                            .padding(.trailing, 16)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(L10n.CurrencyConversion.cardTitle)
                                                .zFont(size: 14, style: Design.Text.tertiary)
                                            
                                            Text(L10n.CurrencyConversion.title)
                                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                        }
                                        .padding(.trailing, 16)
                                        
                                        Spacer(minLength: 0)
                                        
                                        Button {
                                            store.send(.currencyConversionCloseTapped)
                                        } label: {
                                            Asset.Assets.buttonCloseX.image
                                                .zImage(size: 20, style: Design.HintTooltips.defaultFg)
                                        }
                                        .padding(20)
                                        .offset(x: 20, y: -20)
                                    }
                                    
                                    Button {
                                        store.send(.updateDestination(.currencyConversionSetup))
                                    } label: {
                                        Text(L10n.CurrencyConversion.cardButton)
                                            .zFont(.semiBold, size: 16, style: Design.Btns.Tertiary.fg)
                                            .frame(height: 24)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                                            }
                                    }
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                                        }
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
                            }
                        }
                    }
                }
            }
        }
    }
    
//    public var body: some View {
//        WithPerceptionTracking {
//            accountView()
//                .navigationBarTitleDisplayMode(.inline)
//                .navigationBarItems(
//                    leading:
//                        walletAccountSwitcher()
//                )
//                .navigationBarItems(
//                    trailing:
//                        HStack(spacing: 0) {
//                            if store.selectedTab != .receive {
//                                hideBalancesButton()
//                            }
//                            
//                            settingsButton()
//                        }
//                        .animation(nil, value: store.selectedTab)
//                )
//        }
//    }
    
//    public var body2: some View {
//        WithPerceptionTracking {
//            accountView()
            //            .navigationLinkEmpty(
            //                isActive: store.bindingFor(.sendConfirmation),
            //                destination: {
            //                    SendConfirmationView(
            //                        store: store.sendConfirmationStore(),
            //                        tokenName: tokenName
            //                    )
            //                }
            //            )
//            .navigationLinkEmpty(
//                isActive: store.bindingFor(.sendConfirmationKeystone),
//                destination: {
//                    SignWithKeystoneView(store: store.sendConfirmationStore(), tokenName: tokenName)
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingFor(.currencyConversionSetup),
//                destination: {
//                    CurrencyConversionSetupView(
//                        store: store.currencyConversionSetupStore()
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingFor(.addressDetails),
//                destination: {
//                    AddressDetailsView(store: store.addressDetailsStore())
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingForStackAddKeystoneKWWallet(.addKeystoneHWWallet),
//                destination: {
//                    AddKeystoneHWWalletView(
//                        store: store.addKeystoneHWWalletStore()
//                    )
//                    .navigationLinkEmpty(
//                        isActive: store.bindingForStackAddKeystoneKWWallet(.scan),
//                        destination: {
//                            ScanView(
//                                store: store.scanStore()
//                            )
//                            .navigationLinkEmpty(
//                                isActive: store.bindingForStackAddKeystoneKWWallet(.accountSelection),
//                                destination: {
//                                    AccountsSelectionView(
//                                        store: store.addKeystoneHWWalletStore()
//                                    )
//                                }
//                            )
//                        }
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingForStackMaxPrivacy(.zecKeyboard),
//                destination: {
//                    ZecKeyboardView(
//                        store: store.zecKeyboardStore(),
//                        tokenName: tokenName
//                    )
//                    .navigationLinkEmpty(
//                        isActive: store.bindingForStackMaxPrivacy(.requestZec),
//                        destination: {
//                            RequestZecView(
//                                store: store.requestZecStore(),
//                                tokenName: tokenName
//                            )
//                            .navigationLinkEmpty(
//                                isActive: store.bindingForStackMaxPrivacy(.requestZecSummary),
//                                destination: {
//                                    RequestZecSummaryView(
//                                        store: store.requestZecStore(),
//                                        tokenName: tokenName
//                                    )
//                                }
//                            )
//                        }
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingForStackLowPrivacy(.zecKeyboard),
//                destination: {
//                    ZecKeyboardView(
//                        store: store.zecKeyboardStore(),
//                        tokenName: tokenName
//                    )
//                    .navigationLinkEmpty(
//                        isActive: store.bindingForStackLowPrivacy(.requestZecSummary),
//                        destination: {
//                            RequestZecSummaryView(
//                                store: store.requestZecStore(),
//                                tokenName: tokenName
//                            )
//                        }
//                    )
//                }
//            )
                //            .navigationLinkEmpty(
                //                isActive: store.bindingForStackRequestPayment(.requestPaymentConfirmation),
                //                destination: {
                //                    RequestPaymentConfirmationView(
                //                        store: store.sendConfirmationStore(),
                //                        tokenName: tokenName
                //                    )
                //                    .navigationLinkEmpty(
                //                        isActive: store.bindingForStackRequestPayment(.addressBookNewContact),
                //                        destination: {
                //                            AddressBookContactView(store: store.addressBookStore())
                //                        }
                //                    )
                //                }
                //            )
//            .navigationLinkEmpty(
//                isActive: store.bindingForStackTransactions(.manager),
//                destination: {
//                    TransactionsManagerView(
//                        store: store.transactionsManagerStore(),
//                        tokenName: tokenName
//                    )
//                    .navigationLinkEmpty(
//                        isActive: store.bindingForStackTransactions(.details),
//                        destination: {
//                            TransactionDetailsView(
//                                store: store.transactionDetailsStore(),
//                                tokenName: tokenName
//                            )
//                            .navigationLinkEmpty(
//                                isActive: store.bindingForStackTransactions(.addressBook),
//                                destination: {
//                                    AddressBookContactView(store: store.addressBookStore())
//                                }
//                            )
//                        }
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingForStackTransactionsHP(.details),
//                destination: {
//                    TransactionDetailsView(
//                        store: store.transactionDetailsStore(),
//                        tokenName: tokenName
//                    )
//                    .navigationLinkEmpty(
//                        isActive: store.bindingForStackTransactionsHP(.addressBook),
//                        destination: {
//                            AddressBookContactView(store: store.addressBookStore())
//                        }
//                    )
//                }
//            )
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarItems(
//                leading:
//                    walletAccountSwitcher()
//            )
//            .navigationBarItems(
//                trailing:
//                    HStack(spacing: 0) {
//                        if store.selectedTab != .receive {
//                            hideBalancesButton()
//                        }
//                        
//                        settingsButton()
//                    }
//                    .animation(nil, value: store.selectedTab)
//            )
//            //..walletstatusPanel()
//            .sheet(isPresented: $store.isInAppBrowserOn) {
//                if let url = URL(string: store.inAppBrowserURL) {
//                    InAppBrowserView(url: url)
//                }
//            }
//            .sheet(isPresented: $store.accountSwitchRequest) {
//                accountSwitchContent()
//            }
//            .sheet(isPresented: $store.selectTextRequest) {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Spacer()
//                        
//                        Button {
//                            store.send(.dismissSelectTextEditor)
//                        } label: {
//                            Asset.Assets.buttonCloseX.image
//                                .zImage(size: 24, style: Design.Btns.Tertiary.fg)
//                                .padding(8)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(Design.Btns.Tertiary.bg.color(colorScheme))
//                                }
//                        }
//                    }
//                    
//                    TextEditor(text: $store.textToSelect)
//                        .colorBackground(Asset.Colors.background.color)
//                        .background(Asset.Colors.background.color)
//                        .zFont(size: 14, style: Design.Text.primary)
//                }
//                .padding()
//                .applyScreenBackground()
//            }
//            .overlayPreferenceValue(ExchangeRateStaleTooltipPreferenceKey.self) { preferences in
//                WithPerceptionTracking {
//                    if store.isRateTooltipEnabled {
//                        GeometryReader { geometry in
//                            preferences.map {
//                                Tooltip(
//                                    title: L10n.Tooltip.ExchangeRate.title,
//                                    desc: L10n.Tooltip.ExchangeRate.desc
//                                ) {
//                                    store.send(.rateTooltipTapped)
//                                }
//                                .frame(width: geometry.size.width - 40)
//                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
//                            }
//                        }
//                    }
//                }
//            }
//            .overlayPreferenceValue(ExchangeRateFeaturePreferenceKey.self) { preferences in
//                WithPerceptionTracking {
//                    if store.isRateEducationEnabled && store.selectedTab != .receive {
//                        GeometryReader { geometry in
//                            preferences.map {
//                                VStack(alignment: .leading, spacing: 0) {
//                                    HStack(alignment: .top, spacing: 0) {
//                                        Asset.Assets.coinsSwap.image
//                                            .zImage(size: 20, style: Design.Text.primary)
//                                            .padding(10)
//                                            .background {
//                                                Circle()
//                                                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
//                                            }
//                                            .padding(.trailing, 16)
//                                        
//                                        VStack(alignment: .leading, spacing: 5) {
//                                            Text(L10n.CurrencyConversion.cardTitle)
//                                                .zFont(size: 14, style: Design.Text.tertiary)
//                                            
//                                            Text(L10n.CurrencyConversion.title)
//                                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
//                                                .lineLimit(1)
//                                                .minimumScaleFactor(0.5)
//                                        }
//                                        .padding(.trailing, 16)
//                                        
//                                        Spacer(minLength: 0)
//                                        
//                                        Button {
//                                            store.send(.currencyConversionCloseTapped)
//                                        } label: {
//                                            Asset.Assets.buttonCloseX.image
//                                                .zImage(size: 20, style: Design.HintTooltips.defaultFg)
//                                        }
//                                        .padding(20)
//                                        .offset(x: 20, y: -20)
//                                    }
//                                    
//                                    Button {
//                                        store.send(.updateDestination(.currencyConversionSetup))
//                                    } label: {
//                                        Text(L10n.CurrencyConversion.cardButton)
//                                            .zFont(.semiBold, size: 16, style: Design.Btns.Tertiary.fg)
//                                            .frame(height: 24)
//                                            .frame(maxWidth: .infinity)
//                                            .padding(.vertical, 12)
//                                            .background {
//                                                RoundedRectangle(cornerRadius: 12)
//                                                    .fill(Design.Btns.Tertiary.bg.color(colorScheme))
//                                            }
//                                    }
//                                }
//                                .padding(24)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(Design.Surfaces.bgPrimary.color(colorScheme))
//                                        .background {
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
//                                        }
//                                }
//                                .frame(width: geometry.size.width - 40)
//                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}
//
//extension TabsView {
//    @ViewBuilder func accountView() -> some View {
//        WithPerceptionTracking {
////            VStack {
////                HStack {
////                    Button("send") { store.send(.selectedTabChanged(.send)) }
////                    Button("receive") { store.send(.selectedTabChanged(.receive)) }
////                    Button("balances") { store.send(.selectedTabChanged(.balances)) }
////                }
//                HomeView(
//                    store: self.store.scope(
//                        state: \.homeState,
//                        action: \.home
//                    ),
//                    tokenName: tokenName
//                )
////            }
//            .onAppear { store.send(.onAppear) }
//            .navigationLinkEmpty(
//                isActive: store.bindingTabFor(.send),
//                destination: {
//                    SendFormView(
//                        store: self.store.scope(
//                            state: \.sendState,
//                            action: \.send
//                        ),
//                        tokenName: tokenName
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingTabFor(.receive),
//                destination: {
//                    ReceiveView(
//                        store: self.store.scope(
//                            state: \.receiveState,
//                            action: \.receive
//                        ),
//                        networkType: networkType
//                    )
//                }
//            )
//            .navigationLinkEmpty(
//                isActive: store.bindingTabFor(.balances),
//                destination: {
//                    BalancesView(
//                        store: self.store.scope(
//                            state: \.balanceBreakdownState,
//                            action: \.balanceBreakdown
//                        ),
//                        tokenName: tokenName
//                    )
//                }
//            )
//        }
//    }
//}

#Preview {
    NavigationView {
        TabsView(store: .demo, tokenName: "TAZ", networkType: .testnet)
    }
}

// MARK: - Store

extension StoreOf<Tabs> {
    public static var demo = StoreOf<Tabs>(
        initialState: .initial
    ) {
        Tabs()
    }
}

extension StoreOf<Tabs> {
    func settingsStore() -> StoreOf<Settings> {
        self.scope(
            state: \.settingsState,
            action: \.settings
        )
    }
    
    func sendConfirmationStore() -> StoreOf<SendConfirmation> {
        self.scope(
            state: \.sendConfirmationState,
            action: \.sendConfirmation
        )
    }
    
    func currencyConversionSetupStore() -> StoreOf<CurrencyConversionSetup> {
        self.scope(
            state: \.currencyConversionSetupState,
            action: \.currencyConversionSetup
        )
    }
    
    func addressDetailsStore() -> StoreOf<AddressDetails> {
        self.scope(
            state: \.addressDetailsState,
            action: \.addressDetails
        )
    }
    
    func requestZecStore() -> StoreOf<RequestZec> {
        self.scope(
            state: \.requestZecState,
            action: \.requestZec
        )
    }
    
    func zecKeyboardStore() -> StoreOf<ZecKeyboard> {
        self.scope(
            state: \.zecKeyboardState,
            action: \.zecKeyboard
        )
    }
    
    func addressBookStore() -> StoreOf<AddressBook> {
        self.scope(
            state: \.addressBookState,
            action: \.addressBook
        )
    }
    
    func addKeystoneHWWalletStore() -> StoreOf<AddKeystoneHWWallet> {
        self.scope(
            state: \.addKeystoneHWWalletState,
            action: \.addKeystoneHWWallet
        )
    }
    
    func scanStore() -> StoreOf<Scan> {
        self.scope(
            state: \.scanState,
            action: \.scan
        )
    }
    
    func transactionsManagerStore() -> StoreOf<TransactionsManager> {
        self.scope(
            state: \.transactionsManagerState,
            action: \.transactionsManager
        )
    }
    
    func transactionDetailsStore() -> StoreOf<TransactionDetails> {
        self.scope(
            state: \.transactionDetailsState,
            action: \.transactionDetails
        )
    }
}

// MARK: - ViewStore

extension StoreOf<Tabs> {
    func bindingFor(_ destination: Tabs.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
    
    func bindingTabFor(_ selectedTab: Tabs.State.Tab) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.selectedTab == selectedTab },
            set: { self.send(.selectedTabChanged($0 ? selectedTab : .account)) }
        )
    }
    
    func bindingForStackAddKeystoneKWWallet(_ destination: Tabs.State.StackDestinationAddKeystoneHWWallet) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationAddKeystoneHWWallet?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationAddKeystoneHWWalletBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationAddKeystoneHWWallet?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationAddKeystoneHWWallet(rawValue: popIndex)
                        self.send(.updateStackDestinationAddKeystoneHWWallet(popDestination))
                    } else {
                        self.send(.updateStackDestinationAddKeystoneHWWallet(nil))
                    }
                }
            }
        )
    }
    
    func bindingForStackMaxPrivacy(_ destination: Tabs.State.StackDestinationMaxPrivacy) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationMaxPrivacy?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationMaxPrivacyBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationMaxPrivacy?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationMaxPrivacy(rawValue: popIndex)
                        self.send(.updateStackDestinationMaxPrivacy(popDestination))
                    } else {
                        self.send(.updateStackDestinationMaxPrivacy(nil))
                    }
                }
            }
        )
    }
    
    func bindingForStackLowPrivacy(_ destination: Tabs.State.StackDestinationLowPrivacy) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationLowPrivacy?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationLowPrivacyBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationLowPrivacy?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationLowPrivacy(rawValue: popIndex)
                        self.send(.updateStackDestinationLowPrivacy(popDestination))
                    } else {
                        self.send(.updateStackDestinationLowPrivacy(nil))
                    }
                }
            }
        )
    }
    
    func bindingForStackRequestPayment(_ destination: Tabs.State.StackDestinationRequestPayment) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationRequestPayment?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationRequestPaymentBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationRequestPayment?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationRequestPayment(rawValue: popIndex)
                        self.send(.updateStackDestinationRequestPayment(popDestination))
                    } else {
                        self.send(.updateStackDestinationRequestPayment(nil))
                    }
                }
            }
        )
    }
    
    func bindingForStackTransactions(_ destination: Tabs.State.StackDestinationTransactions) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationTransactions?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationTransactionsBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationTransactions?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationTransactions(rawValue: popIndex)
                        self.send(.updateStackDestinationTransactions(popDestination))
                    } else {
                        self.send(.updateStackDestinationTransactions(nil))
                    }
                }
            }
        )
    }
    
    func bindingForStackTransactionsHP(_ destination: Tabs.State.StackDestinationTransactionsHP) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestinationTransactionsHP?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationTransactionsHPBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestinationTransactionsHP?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = Tabs.State.StackDestinationTransactionsHP(rawValue: popIndex)
                        self.send(.updateStackDestinationTransactionsHP(popDestination))
                    } else {
                        self.send(.updateStackDestinationTransactionsHP(nil))
                    }
                }
            }
        )
    }
}

// MARK: - Placeholders

extension Tabs.State {
    public static let initial = Tabs.State(
        balanceBreakdownState: .initial,
        currencyConversionSetupState: .initial,
        destination: nil,
        homeState: .initial,
//        receiveState: .initial,
        requestZecState: .initial,
        selectedTab: .account,
        sendConfirmationState: .initial,
        sendState: .initial,
        settingsState: .initial,
        zecKeyboardState: .initial
    )
}
