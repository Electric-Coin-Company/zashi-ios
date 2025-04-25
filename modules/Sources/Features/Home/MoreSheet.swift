//
//  MoreSheet.swift
//  modules
//
//  Created by Lukáš Korba on 04.03.2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension HomeView {
    @ViewBuilder func moreContent() -> some View {
        WithPerceptionTracking {
            if #available(iOS 16.4, *) {
                moreMainBody()
                    .presentationDetents([.height(moreSheetHeight)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Design.Radius._4xl)
            } else if #available(iOS 16.0, *) {
                moreMainBody()
                    .presentationDetents([.height(moreSheetHeight)])
                    .presentationDragIndicator(.visible)
            } else {
                moreMainBody(stickToBottom: true)
            }
        }
    }
    
    @ViewBuilder func moreMainBody(stickToBottom: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if stickToBottom {
                Spacer()
            }
            
            Text(L10n.More.options)
                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                .padding(.top, 32)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
            
            if store.inAppBrowserURLCoinbase != nil {
                ActionRow(
                    icon: Asset.Assets.Partners.coinbase.image,
                    title: L10n.Settings.buyZecCB,
                    desc: L10n.Settings.coinbaseDesc,
                    customIcon: true,
                    divider: store.featureFlags.flexa
                ) {
                    store.send(.coinbaseTapped)
                }
            }
            
            ActionRow(
                icon: walletStatus == .restoring
                ? Asset.Assets.Partners.flexaDisabled.image
                : Asset.Assets.Partners.flexa.image,
                title: L10n.Settings.flexa,
                desc: L10n.Settings.flexaDesc,
                customIcon: true,
                divider: !store.isKeystoneConnected
            ) {
                store.send(.flexaTapped)
            }
            .disabled(walletStatus == .restoring)
            .padding(.bottom, store.isKeystoneConnected ? 24 : 0)
            
            if !store.isKeystoneConnected {
                ActionRow(
                    icon: Asset.Assets.Partners.keystone.image,
                    title: L10n.Settings.keystone,
                    desc: L10n.Settings.keystoneDesc,
                    customIcon: true,
                    divider: false
                ) {
                    store.send(.addKeystoneHWWalletTapped)
                }
                .padding(.bottom, 24)
            }
            
            HStack(alignment: .top, spacing: 0) {
                Asset.Assets.infoOutline.image
                    .zImage(size: 20, style: Design.Text.tertiary)
                    .padding(.trailing, 12)

                Text(L10n.HomeScreen.moreWarning)
                    .zFont(size: 12, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 24)
            .padding(.top, 16)
            .screenHorizontalPadding()
        }
        .padding(.horizontal, 4)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        moreSheetHeight = proxy.size.height
                    }
            }
        }
    }
}
