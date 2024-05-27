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
                        isActive: viewStore.bindingForDestination(.requestPaymentConfirmation),
                        destination: {
                            RequestPaymentConfirmationView(
                                store: store.sendConfirmationStore(),
                                tokenName: tokenName
                            )
                        }
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForDestination(.sendConfirmation),
                        destination: {
                            SendConfirmationView(
                                store: store.sendConfirmationStore(),
                                tokenName: tokenName
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
