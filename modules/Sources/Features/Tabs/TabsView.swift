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
import HideBalances
import SendConfirmation
import CurrencyConversionSetup

public struct TabsView: View {
    let networkType: NetworkType
    var store: TabsStore
    let tokenName: String
    @Namespace var tabsID

    @Dependency(\.hideBalances) var hideBalances
    @State var areBalancesHidden = false

    public init(store: TabsStore, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            WithViewStore(self.store, observe: \.selectedTab) { tab in
                ZStack {
                    TabView(selection: tab.binding(send: TabsReducer.Action.selectedTabChanged)) {
                        HomeView(
                            store: self.store.scope(
                                state: \.homeState,
                                action: TabsReducer.Action.home
                            ),
                            tokenName: tokenName
                        )
                        .tag(TabsReducer.State.Tab.account)
                        
                        SendFlowView(
                            store: self.store.scope(
                                state: \.sendState,
                                action: TabsReducer.Action.send
                            ),
                            tokenName: tokenName
                        )
                        .tag(TabsReducer.State.Tab.send)
                        
                        AddressDetailsView(
                            store: self.store.scope(
                                state: \.addressDetailsState,
                                action: TabsReducer.Action.addressDetails
                            ),
                            networkType: networkType
                        )
                        .tag(TabsReducer.State.Tab.receive)
                        
                        BalanceBreakdownView(
                            store: self.store.scope(
                                state: \.balanceBreakdownState,
                                action: TabsReducer.Action.balanceBreakdown
                            ),
                            tokenName: tokenName
                        )
                        .tag(TabsReducer.State.Tab.balances)
                    }
                    .onAppear { viewStore.send(.onAppear) }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        if tab.state != .account {
                            Asset.Colors.shade30.color
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .opacity(0.15)
                        }
                        
                        HStack {
                            ForEach((TabsReducer.State.Tab.allCases), id: \.self) { item in
                                Button {
                                    store.send(.selectedTabChanged(item), animation: .easeInOut)
                                } label: {
                                    VStack {
                                        if tab.state == item {
                                            Text("\(item.title)")
                                                .font(.custom(FontFamily.Archivo.black.name, size: 12))
                                                .foregroundColor(Asset.Colors.primary.color)
                                            Rectangle()
                                                .frame(height: 2)
                                                .foregroundColor(Asset.Colors.primaryTint.color)
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
                                    .frame(minHeight: 50)
                                }
                                
                                if item.rawValue < TabsReducer.State.Tab.allCases.count-1 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .background(Asset.Colors.background.color)
                    }
                    .ignoresSafeArea(.keyboard)
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForDestination(.sendConfirmation),
                        destination: {
                            SendConfirmationView(
                                store: store.sendConfirmationStore(),
                                tokenName: tokenName
                            )
                        }
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForDestination(.currencyConversionSetup),
                        destination: {
                            CurrencyConversionSetupView(
                                store: store.currencyConversionSetupStore()
                            )
                        }
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: settingsButton(store))
                .navigationBarItems(leading: hideBalancesButton(store, tab: tab.state))
                .zashiTitle { navBarView(tab.state) }
                .walletStatusPanel()
                .onAppear {
                    areBalancesHidden = hideBalances.value().value
                }
                .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
                    if viewStore.isRateTooltipEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                Tooltip(
                                    title: L10n.Tooltip.ExchangeRate.title,
                                    desc: L10n.Tooltip.ExchangeRate.desc
                                ) {
                                    viewStore.send(.rateTooltipTapped)
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
                            }
                        }
                    }
                }
                .overlayPreferenceValue(ExchangeRateFeaturePreferenceKey.self) { preferences in
                    if viewStore.isRateEducationEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .top, spacing: 0) {
                                        Asset.Assets.coinsSwap.image
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Asset.Colors.CurrencyConversion.optionTint.color)
                                            .padding(10)
                                            .background {
                                                Circle()
                                                    .fill(Asset.Colors.CurrencyConversion.optionBcg.color)
                                            }
                                            .padding(.trailing, 16)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(L10n.CurrencyConversion.cardTitle)
                                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                                .foregroundColor(Asset.Colors.CurrencyConversion.tertiary.color)

                                            Text(L10n.CurrencyConversion.title)
                                                .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                                .foregroundColor(Asset.Colors.CurrencyConversion.primary.color)
                                        }
                                        .padding(.trailing, 16)
                                        
                                        Spacer()
                                        
                                        Button {
                                            viewStore.send(.currencyConversionCloseTapped)
                                        } label: {
                                            Asset.Assets.buttonCloseX.image
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Asset.Colors.CurrencyConversion.Card.close.color)
                                        }
                                        .padding(20)
                                        .offset(x: 20, y: -20)
                                    }

                                    Button {
                                        viewStore.send(.updateDestination(.currencyConversionSetup))
                                    } label: {
                                        Text(L10n.CurrencyConversion.cardButton)
                                            .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                            .foregroundColor(Asset.Colors.CurrencyConversion.primary.color)
                                            .frame(height: 24)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Asset.Colors.CurrencyConversion.btnPrimaryDisabled.color)
                                            }
                                    }
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Asset.Colors.CurrencyConversion.Card.bcg.color)
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Asset.Colors.CurrencyConversion.Card.outline.color)
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
    
    @ViewBuilder private func navBarView(_ tab: TabsReducer.State.Tab) -> some View {
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
    
    func settingsButton(_ store: TabsStore) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Image(systemName: "line.3.horizontal")
                .resizable()
                .frame(width: 21, height: 15)
                .padding(15)
                .navigationLink(
                    isActive: viewStore.bindingForDestination(.settings),
                    destination: {
                        SettingsView(store: store.settingsStore())
                    }
                )
                .tint(Asset.Colors.primary.color)
        }
    }
    
    @ViewBuilder
    func hideBalancesButton(_ store: TabsStore, tab: TabsReducer.State.Tab) -> some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if tab == .account || tab == .send || tab == .balances {
                Button {
                    var prevValue = hideBalances.value().value
                    prevValue.toggle()
                    areBalancesHidden = prevValue
                    hideBalances.updateValue(areBalancesHidden)
                } label: {
                    let image = areBalancesHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
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
}

#Preview {
    NavigationView {
        TabsView(store: .demo, tokenName: "TAZ", networkType: .testnet)
    }
}
