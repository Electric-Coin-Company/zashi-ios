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
                            ActionRow(
                                icon: Asset.Assets.Partners.coinbase.image,
                                title: L10n.Settings.buyZecCB,
                                desc: L10n.Settings.coinbaseDesc,
                                customIcon: true,
                                divider: !store.featureFlags.flexa
                            ) {
                                store.send(.buyZecTapped)
                            }
                        }

                        if store.featureFlags.flexa {
                            ActionRow(
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
                                        .zImage(size: 20, style: Design.Utility.WarningYellow._700)
                                        .padding(.trailing, 12)
                                    
                                    Text(L10n.Settings.restoreWarning)
                                }
                                .zFont(size: 12, style: Design.Utility.WarningYellow._700)
                                .padding(.vertical, 12)
                                .screenHorizontalPadding()
                            }
                        }
                    }
                    .listBackground()
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

                VStack(spacing: 0) {
                    Asset.Assets.Illustrations.lightning.image
                        .resizable()
                        .frame(width: 38, height: 60)

                    Text(L10n.Integrations.info)
                        .zFont(size: 16, style: Design.Text.tertiary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3.0)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Design.Surfaces.bgSecondary.color)
                }
                .padding(.bottom, 24)
                .screenHorizontalPadding()
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .screenTitle(L10n.Settings.integrations)
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
