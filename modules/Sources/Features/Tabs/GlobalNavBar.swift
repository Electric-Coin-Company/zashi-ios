//
//  GlobalNavBar.swift
//  modules
//
//  Created by Lukáš Korba on 26.11.2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Settings

extension TabsView {
    func settingsButton() -> some View {
        Asset.Assets.Icons.menu.image
            .zImage(size: 24, style: Design.Text.primary)
            .padding(8)
            .navigationLink(
                isActive: store.bindingFor(.settings),
                destination: {
                    SettingsView(store: store.settingsStore())
                }
            )
            .tint(Asset.Colors.primary.color)
    }
    
    @ViewBuilder func hideBalancesButton(tab: Tabs.State.Tab) -> some View {
        if tab == .account || tab == .send || tab == .balances {
            Button {
                isSensitiveContentHidden.toggle()
            } label: {
                let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
                image
                    .zImage(size: 24, color: Asset.Colors.primary.color)
                    .padding(8)
            }
        }
    }
    
    @ViewBuilder func walletAccountSwitcher() -> some View {
        Button {
            store.send(.accountSwitchTapped)
        } label: {
            HStack(spacing: 0) {
                store.selectedWalletAccount.vendor.icon()
                    .resizable()
                    .frame(width: 16, height: 16)
                    .background {
                        Circle()
                            .fill(Design.Surfaces.bgAlt.color)
                            .frame(width: 24, height: 24)
                    }

                Text(store.selectedWalletAccount.vendor.name().lowercased())
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.leading, 8)

                Asset.Assets.chevronDown.image
                    .zImage(size: 24, style: Design.Text.primary)
                    .padding(8)
            }
        }
    }
}
