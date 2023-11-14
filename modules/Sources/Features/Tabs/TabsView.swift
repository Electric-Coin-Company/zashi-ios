//
//  WelcomeView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 09.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import AddressDetails
import BalanceBreakdown
import Home
import SendFlow
import Settings

public struct TabsView: View {
    var store: TabsStore
    let tokenName: String
    @Namespace var tabsID

    public init(store: TabsStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithViewStore(self.store, observe: \.selectedTab) { tab in
            WithViewStore(store, observe: { $0 }) { viewStore in
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
                            )
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
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .padding(.bottom, 50)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            ForEach((TabsReducer.State.Tab.allCases), id: \.self) { item in
                                Button {
                                    viewStore.send(.selectedTabChanged(item), animation: .easeInOut)
                                } label: {
                                    VStack {
                                        if viewStore.selectedTab == item {
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
                        .background(Asset.Colors.secondary.color)
                    }
                    .ignoresSafeArea(.keyboard)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: settingsButton(viewStore))
                .zashiTitle { navBarView(tab.state) }
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
                .resizable()
                .frame(width: 62, height: 17)
            
        case .balances:
            Text(L10n.Tabs.balances.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))
        }
    }
    
    func settingsButton(_ viewStore: TabsViewStore) -> some View {
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

#Preview {
    NavigationView {
        TabsView(store: .demo, tokenName: "TAZ")
    }
}
