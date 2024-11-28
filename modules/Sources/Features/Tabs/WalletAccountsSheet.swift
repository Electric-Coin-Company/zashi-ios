//
//  WalletAccountsSheet.swift
//  modules
//
//  Created by Lukáš Korba on 26.11.2024.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension TabsView {
    @ViewBuilder func accountSwitchContent() -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text("Wallets & Hardware")
                    .zFont(.semiBold, size: 20, style: Design.Text.primary)
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)

                // default wallet account only
                if store.walletAccounts.count == 1 {
                    walletAcoountView(
                        icon: Asset.Assets.Icons.zashiLogoSq.image,
                        title: "Zashi",
                        address: "u1078r23uvtj8xj6dpdx...",
                        selected: true
                    )

                    addKeystoneBannerView()
                        .padding(.top, 8)
                } else {
                    walletAcoountView(
                        icon: Asset.Assets.Icons.zashiLogoSq.image,
                        title: "Zashi",
                        address: "u1078r23uvtj8xj6dpdx...",
                        selected: store.selectedWalletAccount.vendor.isDefault()
                    ) {
                        store.send(.walletAccountTapped(true))
                    }
                    
                    walletAcoountView(
                        icon: Asset.Assets.Partners.keystoneLogoInv.image,
                        title: "Keystone",
                        address: "0x8EgiqpBzgfeFqB6cde...",
                        selected: store.selectedWalletAccount.vendor.isHWWallet()
                    ) {
                        store.send(.walletAccountTapped(false))
                    }
                }
                
                ZashiButton(
                    store.walletAccounts.count == 1
                    ? "Connect Hardware Wallet"
                    : "Remove Hardware Wallet",
                    type: .secondary
                ) {
                    store.send(.addKeystoneHWWalletTapped)
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 4)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .task {
                            accountSwitchSheetHeight = proxy.size.height
                        }
                }
            }
            .presentationDetents([.height(accountSwitchSheetHeight)])
            .presentationDragIndicator(.visible)
        }
    }
    
    @ViewBuilder func walletAcoountView(
        icon: Image,
        title: String,
        address: String,
        selected: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        WithPerceptionTracking {
            Button {
                action?()
            } label: {
                HStack(spacing: 0) {
                    icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.brandFg.color)
                        }
                        .padding(.trailing, 12)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .zFont(.semiBold, size: 14, style: Design.Text.primary)
                        
                        Text(address)
                            .zFont(size: 12, style: Design.Text.tertiary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    if selected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Design.Surfaces.bgSecondary.color)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func addKeystoneBannerView() -> some View {
        WithPerceptionTracking {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Asset.Assets.Partners.keystoneLogo.image
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(.trailing, 12)
                    
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Keystone Hardware Wallet")
                        .zFont(.semiBold, size: 18, style: Design.Text.primary)
                    
                    Text("Get a Keystone Hardware Wallet and secure your Zcash.")
                        .zFont(size: 14, style: Design.Text.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                        .padding(.top, 2)
                }
                .padding(.trailing, 12)

                Spacer()
                
                Asset.Assets.chevronRight.image
                    .zImage(size: 24, style: Design.Text.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Design.Surfaces.strokeSecondary.color)
            }
        }
    }
}
