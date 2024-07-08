//
//  IntegrationsView.swift
//
//
//  Created by Lukáš Korba on 2024-09-05.
//

import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents

import Flexa

public struct IntegrationsView: View {
    @Perception.Bindable var store: StoreOf<Integrations>
    
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none
    
    public init(store: StoreOf<Integrations>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                List {
                    Group {
                        if store.inAppBrowserURL != nil {
                            SettingsRow(
                                icon: Asset.Assets.Partners.coinbase.image,
                                title: L10n.Settings.buyZecCB,
                                desc: L10n.Settings.coinbaseDesc,
                                customIcon: true
                            ) {
                                store.send(.buyZecTapped)
                            }
                        }

                        SettingsRow(
                            icon: walletStatus == .restoring
                            ? Asset.Assets.Partners.flexaDisabled.image
                            : Asset.Assets.Partners.flexa.image,
                            title: L10n.Settings.flexa,
                            desc: L10n.Settings.flexaDesc,
                            customIcon: true,
                            divider: false
                        ) {
                            store.send(.flexaTapped)
                        }
                        .disabled(walletStatus == .restoring)
                        
                        if walletStatus == .restoring {
                            HStack(spacing: 0) {
                                Asset.Assets.infoOutline.image
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 12)

                                Text(L10n.Settings.restoreWarning)
                                    .font(.custom(FontFamily.Inter.regular.name, size: 12))
                            }
                            .foregroundColor(Design.Utility.WarningYellow._700.color)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .walletStatusPanel()
                .sheet(isPresented: $store.isInAppBrowserOn) {
                    if let urlStr = store.inAppBrowserURL, let url = URL(string: urlStr) {
                        InAppBrowserView(url: url)
                    }
                }
                .onAppear { store.send(.onAppear) }

                Spacer()
                
                Asset.Assets.zashiTitle.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 73, height: 20)
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.bottom, 16)
                
                Text(L10n.Settings.version(store.appVersion, store.appBuild))
                    .font(.custom(FontFamily.Archivo.regular.name, size: 16))
                    .foregroundColor(Design.Text.tertiary.color)
                    .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .zashiTitle {
            Text(L10n.Settings.integrations.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        IntegrationsView(store: .initial)
    }
}

// MARK: Placeholders

extension Integrations.State {
    public static let initial = Integrations.State()
}

extension StoreOf<Integrations> {
    public static let initial = StoreOf<Integrations>(
        initialState: .initial
    ) {
        Integrations()
    }

    public static let demo = StoreOf<Integrations>(
        initialState: .init()
    ) {
        Integrations()
    }
}
