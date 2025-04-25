//
//  SmartBannerContent.swift
//  modules
//
//  Created by Lukáš Korba on 04-03-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

extension SmartBannerView {
    func titleStyle() -> Color {
        Design.Utility.Purple._50.color(.light)
    }

    func infoStyle() -> Color {
        Design.Utility.Purple._200.color(.light)
    }

    @ViewBuilder func priorityContent() -> some View {
        WithPerceptionTracking {
            switch store.priorityContent {
            case .priority1: disconnectedContent()
            case .priority2: syncingErrorContent()
            case .priority3: restoringContent()
            case .priority4: syncingContent()
            case .priority5: updatingBalanceContent()
            case .priority6: walletBackupContent()
            case .priority7: shieldingContent()
            case .priority8: currencyConversionContent()
            case .priority9: autoShieldingContent()
            default: EmptyView()
            }
        }
    }

    @ViewBuilder func disconnectedContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.wifiOff.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.Disconnected.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.Disconnected.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
        }
    }

    @ViewBuilder func syncingErrorContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.alertTriangle.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.SyncingError.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.SyncingError.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
        }
    }

    @ViewBuilder func restoringContent() -> some View {
        HStack(spacing: 0) {
            CircularProgressView(progress: store.syncingPercentage)
                .frame(width: 20, height: 20)
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.Restore.title(String(format: "%0.1f%%", store.lastKnownSyncPercentage * 100)))
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(store.areFundsSpendable
                     ? L10n.SmartBanner.Content.Restore.infoSpendable
                     : L10n.SmartBanner.Content.Restore.info
                )
                .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
        }
    }

    @ViewBuilder func syncingContent() -> some View {
        HStack(spacing: 0) {
            CircularProgressView(progress: store.syncingPercentage)
                .frame(width: 20, height: 20)
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.Sync.title(String(format: "%0.1f%%", store.lastKnownSyncPercentage * 100)))
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.Sync.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
        }
    }

    @ViewBuilder func updatingBalanceContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.loading.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.UpdatingBalance.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.UpdatingBalance.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
        }
    }

    @ViewBuilder func walletBackupContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.alertTriangle.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.Backup.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.Backup.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
            
            ZashiButton(
                L10n.SmartBanner.Content.Backup.button,
                type: .ghost,
                infinityWidth: false
            ) {
                store.send(.walletBackupTapped)
            }
        }
    }

    @ViewBuilder func shieldingContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.shieldOff.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                ViewThatFits {
                    Text(L10n.SmartBanner.Content.Shield.title)
                        .zFont(.medium, size: 14, color: titleStyle())

                    Text(L10n.SmartBanner.Content.Shield.titleShorter)
                        .zFont(.medium, size: 14, color: titleStyle())
                }
                
                ZatoshiText(store.transparentBalance, .expanded, store.tokenName)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
            
            ZashiButton(
                L10n.SmartBanner.Content.Shield.button,
                type: .ghost,
                infinityWidth: false
            ) {
                if store.isShieldingAcknowledgedAtKeychain {
                    store.send(.shieldFundsTapped)
                } else {
                    store.send(.smartBannerContentTapped)
                }
            }
            .disabled(store.isShielding)
        }
    }

    @ViewBuilder func currencyConversionContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.coinsSwap.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.CurrencyConversion.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.CurrencyConversion.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
            
            ZashiButton(
                L10n.SmartBanner.Content.CurrencyConversion.button,
                type: .ghost,
                infinityWidth: false
            ) {
                store.send(.currencyConversionTapped)
            }
        }
    }

    @ViewBuilder func autoShieldingContent() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Icons.shieldZap.image
                .zImage(size: 20, color: titleStyle())
                .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.SmartBanner.Content.AutoShielding.title)
                    .zFont(.medium, size: 14, color: titleStyle())
                
                Text(L10n.SmartBanner.Content.AutoShielding.info)
                    .zFont(.medium, size: 12, color: infoStyle())
            }
            
            Spacer()
            
            ZashiButton(
                L10n.SmartBanner.Content.AutoShielding.button,
                type: .ghost,
                infinityWidth: false
            ) {
                store.send(.autoShieldingTapped)
            }
        }
    }
}
