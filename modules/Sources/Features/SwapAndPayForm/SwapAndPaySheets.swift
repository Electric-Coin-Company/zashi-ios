//
//  BalancesSheet.swift
//  modules
//
//  Created by Lukáš Korba on 26.05.2025.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import SwapAndPay

import BalanceBreakdown

extension AddressChainTokenView {
    @ViewBuilder func balancesContent() -> some View {
        WithPerceptionTracking {
            BalancesView(
                store:
                    store.scope(
                        state: \.balancesState,
                        action: \.balances
                    ),
                tokenName: tokenName
            )
        }
    }
    
    @ViewBuilder func assetContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    VStack {
                        Text(L10n.SwapAndPay.selectToken.uppercased())
                            .zFont(.semiBold, size: 16, style: Design.Text.primary)
                            .fixedSize()
                    }
                    
                    HStack {
                        Button {
                            store.send(.closeAssetsSheetTapped)
                        } label: {
                            Asset.Assets.buttonCloseX.image
                                .zImage(size: 24, style: Design.Text.primary)
                                .padding(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)

                ZashiTextField(
                    text: $store.searchTerm,
                    placeholder: L10n.SwapAndPay.search,
                    eraseAction: { store.send(.eraseSearchTermTapped) },
                    accessoryView: !store.searchTerm.isEmpty ? Asset.Assets.Icons.xClose.image
                        .zImage(size: 16, style: Design.Btns.Tertiary.fg) : nil,
                    prefixView: Asset.Assets.Icons.search.image
                        .zImage(size: 20, style: Design.Dropdowns.Default.text)
                )
                .padding(.trailing, 8)
                .padding(.bottom, 32)
                .padding(.horizontal, 20)

                List {
                    WithPerceptionTracking {
                        ForEach(store.swapAssets, id: \.self) { asset in
                            assetView(asset, colorScheme)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Asset.Colors.background.color)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .padding(.vertical, 1)
                .background(Asset.Colors.background.color)
                .listStyle(.plain)
            }
        }
    }
    
    @ViewBuilder private func assetView(_ asset: SwapAsset, _ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    asset.tokenIcon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 12)
                        .overlay {
                            ZStack {
                                Circle()
                                    .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                    .frame(width: 22, height: 22)
                                    .offset(x: 8, y: 12)

                                asset.chainIcon
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .offset(x: 8, y: 12)
                            }
                        }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(asset.token)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 14))
                            .zForegroundColor(Design.Text.primary)
                        
                        Text(asset.chainName)
                            .font(.custom(FontFamily.Inter.regular.name, size: 14))
                            .zForegroundColor(Design.Text.tertiary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.top, 2)
                    }
                    .padding(.trailing, 16)
                    
                    Spacer(minLength: 2)
                    
                    Asset.Assets.chevronRight.image
                        .zImage(size: 20, style: Design.Text.tertiary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)

                Design.Surfaces.divider.color(colorScheme)
                    .frame(height: 1)
            }
        }
    }
}

extension SwapAndPayForm {
    @ViewBuilder func slippageContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    store.send(.closeSlippageSheetTapped)
                } label: {
                    Asset.Assets.buttonCloseX.image
                        .zImage(size: 24, style: Design.Text.primary)
                        .padding(8)
                }
                .padding(.vertical, 24)

                Text(L10n.SwapAndPay.slippage)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.bottom, 8)

                Text(L10n.SwapAndPay.slippageDesc)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 24)

                VStack(spacing: 0) {
                    Slider(value: $store.slippage, in: 0...40, step: 1) {
                        
                    }
                    .tint(Design.Text.primary.color(colorScheme))

                    HStack(spacing: 0) {
                        ForEach(0..<4) { i in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: 1, height: 8)
                                    .foregroundColor(Design.Text.primary.color(colorScheme))
                                    .padding(.leading, i == 0 ? 12 : 0)

                                Spacer()
                                
                                if i == 3 {
                                    Rectangle()
                                        .frame(width: 1, height: 8)
                                        .foregroundColor(Design.Text.primary.color(colorScheme))
                                        .padding(.trailing, 12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 0) {
                        ForEach(0..<4) { i in
                            HStack(spacing: 0) {
                                Text("\(i)%")
                                    .foregroundColor(Design.Text.primary.color(colorScheme))

                                Spacer()
                                
                                if i == 3 {
                                    Text("custom")
                                        .foregroundColor(Design.Text.primary.color(colorScheme))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                }
                .padding(.bottom, 32)
                
                HStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Asset.Assets.infoCircle.image
                            .zImage(size: 20, style: Design.Utility.Gray._600)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Low Slippage")
                                .zFont(.semiBold, size: 14, style: Design.Utility.Gray._600)
                                .padding(.bottom, 4)

                            Text("You will only pay up to 1% ($1.01) for the swap but the transaction is less likely to succeed.")
                                .zFont(size: 12, style: Design.Utility.Gray._900)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                        .fill(Design.Utility.Gray._50.color(colorScheme))
                }
                
                Spacer()
                
                ZashiButton(L10n.General.confirm) {
                    
                }
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder func quoteUnavailableContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Asset.Assets.Icons.alertOutline.image
                    .zImage(size: 24, style: Design.Utility.ErrorRed._500)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._full)
                            .fill(Design.Utility.ErrorRed._50.color(colorScheme))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                Text(L10n.SwapAndPay.quoteUnavailable)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.bottom, 8)

                Text("We tried but couldn’t get a quote for a payment with your parameters. You can try to adjust the payment details or try again later.")
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                ZashiButton(
                    L10n.SwapAndPay.cancelPayment,
                    type: .destructive1
                ) {
                    
                }
                .padding(.bottom, 8)

                ZashiButton(L10n.SwapAndPay.editPayment) {
                    
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    @ViewBuilder func quoteContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Text(L10n.SwapAndPay.payNow)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.vertical, 24)

                ZStack {
                    HStack(spacing: 8) {
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Text("2.4776156")
                                    .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                
                                Asset.Assets.Partners.keystoneSeekLogo.image
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text("$101.00")
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._2xl)
                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Text("2.4776156")
                                    .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                
                                Asset.Assets.Partners.keystoneSeekLogo.image
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text("$101.00")
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._2xl)
                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                        }
                    }
                    
                    Asset.Assets.Icons.arrowRight.image
                        .zImage(size: 16, style: Design.Text.tertiary)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._full)
                                .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                .background {
                                    RoundedRectangle(cornerRadius: Design.Radius._full)
                                        .stroke(Design.Utility.Gray._100.color(colorScheme))
                                }
                        }
                        .shadow(color: .black.opacity(0.02), radius: 0.66667, x: 0, y: 1.33333)
                        .shadow(color: .black.opacity(0.08), radius: 1.33333, x: 0, y: 1.33333)
                }
                .padding(.bottom, 32)

                quoteLineContent(L10n.SwapAndPay.payFrom, "Zashi")
                    .padding(.bottom, 12)
                
                quoteLineContent(L10n.SwapAndPay.payTo, "0xcaC4Df16470B6b266C...")
                    .padding(.bottom, 12)

                quoteLineContent(L10n.SwapAndPay.fee, "0.001 ZEC")
                    .padding(.bottom, 12)

                quoteLineContent(L10n.SwapAndPay.maxSlippage("1"), "0.02453084 ZEC")
                HStack(spacing: 0) {
                    Spacer()

                    Text("$1.00")
                        .zFont(.medium, size: 12, style: Design.Text.tertiary)
                }

                Divider()
                    .frame(height: 1)
                    .background(Design.Surfaces.strokeSecondary.color(colorScheme))
                    .padding(.vertical, 12)
                
                HStack(spacing: 0) {
                    Text(L10n.SwapAndPay.totalAmount)
                        .zFont(.medium, size: 14, style: Design.Text.primary)

                    Spacer()

                    Text("2.50314644 ZEC")
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                }
                HStack(spacing: 0) {
                    Spacer()

                    Text("$102.04")
                        .zFont(.medium, size: 12, style: Design.Text.tertiary)
                }
                .padding(.bottom, 32)
                
                ZashiButton(L10n.General.confirm) {
                    
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    @ViewBuilder private func quoteLineContent(
        _ info: String,
        _ value: String
    ) -> some View {
        HStack(spacing: 0) {
            Text(info)
                .zFont(size: 14, style: Design.Text.tertiary)

            Spacer()

            Text(value)
                .zFont(.medium, size: 14, style: Design.Text.primary)
        }
    }
}
