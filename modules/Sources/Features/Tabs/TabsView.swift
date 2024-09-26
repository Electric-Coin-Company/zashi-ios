//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 09.10.2023.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import AddressDetails
import BalanceBreakdown
import Home
import SendFlow
import Settings
import UIComponents
import SendConfirmation
import CurrencyConversionSetup

public struct TabsView: View {
    let networkType: NetworkType
    @Perception.Bindable var store: StoreOf<Tabs>
    let tokenName: String
    @Namespace var tabsID

    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    
    public init(store: StoreOf<Tabs>, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }

    public var body: some View {
        WithPerceptionTracking {
            ZStack {
                TabView(selection: $store.selectedTab) {
                    HomeView(
                        store: self.store.scope(
                            state: \.homeState,
                            action: \.home
                        ),
                        tokenName: tokenName
                    )
                    .tag(Tabs.State.Tab.account)
                    
                    SendFlowView(
                        store: self.store.scope(
                            state: \.sendState,
                            action: \.send
                        ),
                        tokenName: tokenName
                    )
                    .tag(Tabs.State.Tab.send)
                    
                    AddressDetailsView(
                        store: self.store.scope(
                            state: \.addressDetailsState,
                            action: \.addressDetails
                        ),
                        networkType: networkType
                    )
                    .tag(Tabs.State.Tab.receive)
                    
                    BalancesView(
                        store: self.store.scope(
                            state: \.balanceBreakdownState,
                            action: \.balanceBreakdown
                        ),
                        tokenName: tokenName
                    )
                    .tag(Tabs.State.Tab.balances)
                }
                .onAppear { store.send(.onAppear) }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    if store.selectedTab != .account {
                        Asset.Colors.shade30.color
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .opacity(0.15)
                    }
                    
                    HStack {
                        ForEach((Tabs.State.Tab.allCases), id: \.self) { item in
                            Button {
                                store.send(.selectedTabChanged(item), animation: .easeInOut)
                            } label: {
                                VStack {
                                    WithPerceptionTracking {
                                        if store.selectedTab == item {
                                            Text("\(item.title)")
                                                .font(.custom(FontFamily.Archivo.black.name, size: 12))
                                                .foregroundColor(Asset.Colors.primary.color)
                                            Rectangle()
                                                .frame(height: 2)
                                                .foregroundColor(Design.Surfaces.brandBg.color)
                                                .matchedGeometryEffect(id: "Tabs", in: tabsID, properties: .frame)
                                        } else {
                                            Text("\(item.title)")
                                                .font(.custom(FontFamily.Archivo.regular.name, size: 12))
                                                .foregroundColor(Asset.Colors.primary.color)
                                            Rectangle()
                                                .frame(height: 2)
                                                .foregroundColor(.clear)
                                        }
                                    }
                                }
                                .frame(minHeight: 50)
                            }
                            
                            if item.rawValue < Tabs.State.Tab.allCases.count-1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .background(Asset.Colors.background.color)
                }
                .ignoresSafeArea(.keyboard)
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.sendConfirmation),
                    destination: {
                        SendConfirmationView(
                            store: store.sendConfirmationStore(),
                            tokenName: tokenName
                        )
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: settingsButton())
            .navigationBarItems(leading: hideBalancesButton(tab: store.selectedTab))
            .zashiTitle { navBarView(store.selectedTab) }
            .walletStatusPanel()
            .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
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
                    if store.isRateEducationEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .top, spacing: 0) {
                                        Asset.Assets.coinsSwap.image
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Design.Text.primary.color)
                                            .padding(10)
                                            .background {
                                                Circle()
                                                    .fill(Design.Surfaces.bgTertiary.color)
                                            }
                                            .padding(.trailing, 16)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(L10n.CurrencyConversion.cardTitle)
                                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                                .foregroundColor(Design.Text.tertiary.color)
                                            
                                            Text(L10n.CurrencyConversion.title)
                                                .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                                .foregroundColor(Design.Text.primary.color)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                        }
                                        .padding(.trailing, 16)
                                        
                                        Spacer(minLength: 0)
                                        
                                        Button {
                                            store.send(.currencyConversionCloseTapped)
                                        } label: {
                                            Asset.Assets.buttonCloseX.image
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Design.HintTooltips.defaultFg.color)
                                        }
                                        .padding(20)
                                        .offset(x: 20, y: -20)
                                    }
                                    
                                    Button {
                                        store.send(.updateDestination(.currencyConversionSetup))
                                    } label: {
                                        Text(L10n.CurrencyConversion.cardButton)
                                            .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                            .foregroundColor(Design.Btns.Tertiary.fg.color)
                                            .frame(height: 24)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Design.Btns.Tertiary.bg.color)
                                            }
                                    }
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.Surfaces.bgPrimary.color)
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Design.Surfaces.strokeSecondary.color)
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
    
    @ViewBuilder private func navBarView(_ tab: Tabs.State.Tab) -> some View {
        switch tab {
        case .receive, .send:
            Text(tab.title.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))

        case .account:
            Asset.Assets.zashiTitle.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 62, height: 17)
                .foregroundColor(Asset.Colors.primary.color)

        case .balances:
            Text(L10n.Tabs.balances.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))
        }
    }
    
    func settingsButton() -> some View {
        Image(systemName: "line.3.horizontal")
            .resizable()
            .frame(width: 21, height: 15)
            .padding(15)
            .navigationLink(
                isActive: store.bindingFor(.settings),
                destination: {
                    SettingsView(store: store.settingsStore())
                }
            )
            .tint(Asset.Colors.primary.color)
    }
    
    @ViewBuilder
    func hideBalancesButton(tab: Tabs.State.Tab) -> some View {
        if tab == .account || tab == .send || tab == .balances {
            Button {
                isSensitiveContentHidden.toggle()
            } label: {
                let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
                image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(15)
                    .tint(Asset.Colors.primary.color)
            }
        }
    }
}

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
}

// MARK: - ViewStore

extension StoreOf<Tabs> {
    func bindingFor(_ destination: Tabs.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}

// MARK: - Placeholders

extension Tabs.State {
    public static let initial = Tabs.State(
        addressDetailsState: .initial,
        balanceBreakdownState: .initial,
        currencyConversionSetupState: .initial,
        destination: nil,
        homeState: .initial,
        selectedTab: .account,
        sendConfirmationState: .initial,
        sendState: .initial,
        settingsState: .initial
    )
}
