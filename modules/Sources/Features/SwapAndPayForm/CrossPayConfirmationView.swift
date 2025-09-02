//
//  CrossPayConfirmation.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-01-2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import SwapAndPay

import UIComponents

public struct CrossPayConfirmationView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<SwapAndPay>
    let tokenName: String
    
    public init(store: StoreOf<SwapAndPay>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center, spacing: 0) {
                Text(L10n.Crosspay.paymentAmount)
                    .zFont(.medium, size: 16, style: Design.Text.primary)
                    .padding(.top, 36)
                    .padding(.vertical, 12)

                HStack(spacing: 12) {
                    payTokenTicker(asset: store.selectedAsset, colorScheme)
                        .offset(y: -4)

                    Text(store.tokenToBeReceivedInQuote)
                        .zFont(.semiBold, size: 48, style: Design.Text.primary)
                        .padding(.bottom, 8)
                }

                Text(store.tokenUsdToBeReceivedInQuote)
                    .zFont(.medium, size: 18, style: Design.Text.tertiary)
                    .padding(.bottom, 28)
                
                // Sending to
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.Send.toSummary)
                            .zFont(.medium, size: 14, style: Design.Text.primary)

                        if let alias = store.selectedContact?.name {
                            Text(alias)
                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                        }
                        
                        Text(store.address)
                            .zFont(addressFont: true, size: 12, style: Design.Text.primary)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                
                // Sending from
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.Crosspay.sendingFrom)
                            .zFont(.medium, size: 14, style: Design.Text.primary)
                            .padding(.bottom, 6)

                        HStack(spacing: 8) {
                            zecTickerLogo(colorScheme)
                            
                            Text(L10n.SwapAndPay.Quote.zashi)
                                .zFont(.medium, size: 14, style: Design.Text.primary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20)

                // Amount
                HStack {
                    Text(L10n.Send.amount)
                        .zFont(size: 14, style: Design.Text.tertiary)

                    Spacer()
                    
                    Text("\(store.zecToBeSpendInQuote) \(tokenName)")
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                }
                .padding(.bottom, 12)

                // Fee
                HStack {
                    Text(L10n.Send.feeSummary)
                        .zFont(size: 14, style: Design.Text.tertiary)

                    Spacer()
                    
                    Text("\(store.totalFeesStr) \(tokenName)")
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                }

                Divider()
                    .frame(height: 1)
                    .background(Design.Surfaces.strokeSecondary.color(colorScheme))
                    .padding(.vertical, 12)

                // Total Amount
                HStack {
                    Text(L10n.Crosspay.total)
                        .zFont(size: 14, style: Design.Text.tertiary)

                    Spacer()

                    Text("\(store.totalZecToBeSpendInQuote) \(tokenName)")
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                }

                HStack {
                    Spacer()
                    
                    Text(store.totalZecUsdToBeSpendInQuote)
                        .zFont(size: 12, style: Design.Text.tertiary)
                }
                .padding(.top, 2)
                
                Spacer()
                
                if store.selectedWalletAccount?.vendor == .keystone {
                    ZashiButton(L10n.Keystone.confirm) {
                        store.send(.confirmWithKeystoneTapped)
                    }
                    .padding(.bottom, 24)
                } else {
                    ZashiButton(L10n.Crosspay.pay) {
                        store.send(.confirmButtonTapped)
                    }
                    .padding(.bottom, 24)
                }
            }
            .zashiBack {
                store.send(.backFromConfirmationTapped)
            }
            .screenTitle(
                store.selectedWalletAccount?.vendor == .keystone
                ? L10n.Send.review
                : L10n.Send.confirmationTitle
            )
            .screenHorizontalPadding()
            .applyScreenBackground()
        }
    }
    
    @ViewBuilder func payTokenTicker(asset: SwapAsset?, _ colorScheme: ColorScheme) -> some View {
        if let asset {
            asset.tokenIcon
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 8)
                .overlay {
                    ZStack {
                        Circle()
                            .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                            .frame(width: 26, height: 26)
                            .offset(x: 13, y: 13)
                        
                        asset.chainIcon
                            .resizable()
                            .frame(width: 22, height: 22)
                            .offset(x: 12, y: 12)
                    }
                }
        }
    }
    
    @ViewBuilder func zecTickerLogo(_ colorScheme: ColorScheme) -> some View {
        Asset.Assets.zashiLogo.image
            .zImage(width: 14, height: 20, color: Design.Surfaces.bgPrimary.color(colorScheme))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background {
                Circle()
                    .fill(Design.Surfaces.bgAlt.color(colorScheme))
            }
    }
}

#Preview {
    NavigationView {
        CrossPayConfirmationView(store: SwapAndPay.initial, tokenName: "ZEC")
    }
}
