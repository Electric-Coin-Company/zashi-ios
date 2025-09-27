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
        VStack(alignment: .leading, spacing: 0) {
//            ActionRow(
//                icon: walletStatus == .restoring
//                ? Asset.Assets.Partners.payWithNearDisabled.image
//                : Asset.Assets.Partners.payWithNear.image,
//                title: L10n.SendSelect.payWithNear,
//                desc: L10n.SendSelect.PayWithNear.desc,
//                customIcon: true
//            ) {
//                store.send(.payWithNearTapped)
//            }
//            .disabled(walletStatus == .restoring)
//            .padding(.top, 32)
//
            ActionRow(
                icon: walletStatus == .restoring
                ? Asset.Assets.Partners.payWithNearDisabled.image
                : Asset.Assets.Partners.payWithNear.image,
                title: L10n.SendSelect.swapWithNear,
                desc: L10n.SendSelect.SwapWithNear.desc,
                customIcon: store.featureFlags.flexa
            ) {
                store.send(.swapWithNearTapped)
            }
            .disabled(walletStatus == .restoring)
            .padding(.top, 32)

            if !store.isKeystoneAccountActive {
                ActionRow(
                    icon: walletStatus == .restoring
                    ? Asset.Assets.Partners.flexaDisabled.image
                    : Asset.Assets.Partners.flexa.image,
                    title: L10n.Settings.flexa,
                    desc: L10n.Settings.flexaDesc,
                    customIcon: true,
                    divider: store.featureFlags.flexa && !store.isKeystoneAccountActive
                ) {
                    store.send(.flexaTapped)
                }
                .disabled(walletStatus == .restoring)
                .padding(.bottom, store.isKeystoneAccountActive ? 24 : 0)
            }
            
            // FIXME: Temporarily disabled until we resolve the issue with Secure Init
            // When done, revert to Asset.Assets.Partners.coinbase.image and remove .disabled(true)
            // Desc revert to L10n.Settings.coinbaseDesc
            if store.inAppBrowserURLCoinbase != nil {
                ActionRow(
                    icon: Asset.Assets.Partners.coinbaseDisabled.image,
                    title: L10n.Settings.buyZecCB,
                    desc: L10n.Coinbase.disabled,
                    customIcon: true,
                    divider: !store.isKeystoneConnected
                ) {
                    store.send(.coinbaseTapped)
                }
                .padding(.bottom, store.isKeystoneConnected ? 24 : 0)
                .padding(.top, store.inAppBrowserURLCoinbase != nil ? 0 : 32)
                .disabled(true)
            }

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
    }
    
    @ViewBuilder func sendRequestContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ActionRow(
                icon: Asset.Assets.Brandmarks.brandmarkMaxBranded.image,
                title: L10n.Crosspay.sendZec,
                desc: L10n.Crosspay.sendZecDesc,
                customIcon: true,
                divider: false
            ) {
                store.send(.sendTapped)
            }
            .padding(.top, 32)
            .padding(.bottom, 16)

            ActionRow(
                icon: Asset.Assets.Tickers.near.image,
                title: L10n.Crosspay.title,
                desc: L10n.Crosspay.sendPayDesc,
                customIcon: true,
                divider: false
            ) {
                store.send(.payWithNearTapped)
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder func payRequestContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ActionRow(
                icon: walletStatus == .restoring
                ? Asset.Assets.Partners.payWithNearDisabled.image
                : Asset.Assets.Partners.payWithNear.image,
                title: L10n.SendSelect.payWithNear,
                desc: L10n.SendSelect.PayWithNear.desc,
                customIcon: true,
                divider: !store.isKeystoneAccountActive
            ) {
                store.send(.payWithNearTapped)
            }
            .disabled(walletStatus == .restoring)
            .padding(.top, 32)
            .padding(.bottom, 8)

            if !store.isKeystoneAccountActive {
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
            .padding(.bottom, 32)
            .padding(.top, 16)
            .screenHorizontalPadding()
        }
        .padding(.horizontal, 4)
    }
}
