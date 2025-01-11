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
    
    @ViewBuilder func hideBalancesButton() -> some View {
        Button {
            $isSensitiveContentHidden.withLock { $0.toggle() }
        } label: {
            let image = isSensitiveContentHidden ? Asset.Assets.eyeOff.image : Asset.Assets.eyeOn.image
            image
                .zImage(size: 24, color: Asset.Colors.primary.color)
                .padding(8)
        }
    }
    
    @ViewBuilder func walletAccountSwitcher() -> some View {
        Button {
            store.send(.accountSwitchTapped)
        } label: {
            HStack(spacing: 0) {
                if let selectedWalletAccount = store.selectedWalletAccount {
                    selectedWalletAccount.vendor.icon()
                        .resizable()
                        .frame(width: 16, height: 16)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.bgAlt.color(colorScheme))
                                .frame(width: 24, height: 24)
                        }
                    
                    Text(selectedWalletAccount.vendor.name().lowercased())
                        .zFont(.semiBold, size: 24, style: Design.Text.primary)
                        .padding(.leading, 8)
                }

                Asset.Assets.chevronDown.image
                    .zImage(size: 24, style: Design.Text.primary)
                    .padding(8)
            }
        }
    }
}
