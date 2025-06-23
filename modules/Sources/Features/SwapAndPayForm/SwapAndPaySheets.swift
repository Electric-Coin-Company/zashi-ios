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

extension SwapAndPayForm {
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
                .padding(.top, 16)
                .padding(.bottom, 24)
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
                        ForEach(store.swapAssetsToPresent, id: \.self) { asset in
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
            Button {
                store.send(.assetTapped(asset))
            } label: {
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
                    
                    if store.swapAssetsToPresent.last != asset {
                        Design.Surfaces.divider.color(colorScheme)
                            .frame(height: 1)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func slippageContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            ScrollView {
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

                    HStack(spacing: 0) {
                        slippageChip(index: 0, text: store.slippage05String, colorScheme)
                        slippageChip(index: 1, text: store.slippage1String, colorScheme)
                        slippageChip(index: 2, text: store.slippage2String, colorScheme)
                        
                        if store.selectedSlippageChip == 3 {
                            HStack(spacing: 0) {
                                Spacer()
                                
                                TextField(
                                    "",
                                    text: $store.customSlippage,
                                    prompt:
                                        Text(store.slippage0String)
                                        .font(.custom(FontFamily.Inter.medium.name, size: 16))
                                        .foregroundColor(Design.Switcher.selectedText.color(colorScheme))
                                )
                                .zFont(.medium, size: 16, style: Design.Switcher.selectedText)
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                                .focused($isSlippageFocused)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        isSlippageFocused = true
                                    }
                                }

                                if !store.customSlippage.isEmpty {
                                    Text("%")
                                        .zFont(.medium, size: 16, style: Design.Switcher.selectedText)
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background {
                                RoundedRectangle(cornerRadius: Design.Radius._lg)
                                    .fill(Design.Switcher.selectedBg.color(colorScheme))
                                    .background {
                                        RoundedRectangle(cornerRadius: Design.Radius._lg)
                                            .stroke(Design.Switcher.selectedStroke.color(colorScheme))
                                    }
                            }
                        } else {
                            Text(L10n.SwapAndPay.custom)
                                .zFont(.medium, size: 16, style: Design.Switcher.defaultText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    store.send(.slippageChipTapped(3))
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 2)
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._lg)
                            .fill(Design.Switcher.surfacePrimary.color(colorScheme))
                    }
                    .padding(.top, 24)

                    Group {
                        Text(L10n.SwapAndPay.slippageSet1)
                        + Text(
                            L10n.SwapAndPay.slippageSet2(
                                store.currentSlippageInSheetString,
                                store.slippageDiff
                            )
                        ).bold()
                        + Text(L10n.SwapAndPay.slippageSet3)
                    }
                    .zFont(size: 12, style: slippageWarnTextStyle())
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._lg)
                            .fill(slippageWarnBcgColor(colorScheme))
                    }
                    .padding(.vertical, 20)

                    Text(L10n.SwapAndPay.slippageWarn)
                        .zFont(size: 12, style: Design.Text.tertiary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                    
                    ZashiButton(L10n.General.confirm) {
                        store.send(.slippageSetConfirmTapped)
                    }
                    .padding(.top, 36)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 1)
        }
    }
    
    @ViewBuilder private func slippageChip(index: Int, text: String, _ colorScheme: ColorScheme) -> some View {
        if store.selectedSlippageChip == index {
            Text(text)
                .zFont(.medium, size: 16, style: Design.Switcher.selectedText)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._lg)
                        .fill(Design.Switcher.selectedBg.color(colorScheme))
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._lg)
                                .stroke(Design.Switcher.selectedStroke.color(colorScheme))
                        }
                }
                .onTapGesture {
                    store.send(.slippageChipTapped(index))
                }
        } else {
            Text(text)
                .zFont(.medium, size: 16, style: Design.Switcher.defaultText)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .onTapGesture {
                    store.send(.slippageChipTapped(index))
                }
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

                Text(store.quoteUnavailableErrorMsg)
                    .zFont(size: 14, style: Design.Text.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                ZashiButton(
                    L10n.SwapAndPay.cancelPayment,
                    type: .destructive1
                ) {
                    store.send(.cancelPaymentTapped)
                }
                .padding(.bottom, 8)

                ZashiButton(L10n.SwapAndPay.editPayment) {
                    store.send(.editPaymentTapped)
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    @ViewBuilder func quoteContent(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Text(
                    store.isSwapExperienceEnabled
                    ? L10n.SwapAndPay.swapNow
                    : L10n.SwapAndPay.payNow
                )
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.vertical, 24)

                ZStack {
                    HStack(spacing: 8) {
                        VStack(spacing: 0) {
                            HStack(spacing: 2) {
                                Text(store.zecToBeSpendInQuote)
                                    .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                
                                zecTickerLogo(colorScheme)
                                    .scaleEffect(0.8)
                            }
                            
                            Text(store.zecUsdToBeSpendInQuote)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._xl)
                                .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 2) {
                                Text(store.tokenToBeReceivedInQuote)
                                    .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)

                                tokenTicker(asset: store.selectedAsset, colorScheme)
                                    .scaleEffect(0.8)
                            }
                            
                            Text(store.tokenUsdToBeReceivedInQuote)
                                .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: Design.Radius._xl)
                                .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                        }
                    }
                    
                    Asset.Assets.Icons.arrowRight.image
                        .zImage(size: 16, style: Design.Text.tertiary)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                .frame(width: 32, height: 32)
                        }
                        .shadow(color: .black.opacity(0.02), radius: 0.66667, x: 0, y: 1.33333)
                        .shadow(color: .black.opacity(0.08), radius: 1.33333, x: 0, y: 1.33333)
                }
                .padding(.bottom, 32)

                quoteLineContent(
                    store.isSwapExperienceEnabled
                    ? L10n.SwapAndPay.swapFrom
                    : L10n.SwapAndPay.payFrom,
                    L10n.SwapAndPay.Quote.zashi
                )
                .padding(.bottom, 12)
                
                quoteLineContent(
                    store.isSwapExperienceEnabled
                    ? L10n.SwapAndPay.swapTo
                    : L10n.SwapAndPay.payTo,
                    store.address.zip316
                )
                .padding(.bottom, 12)

                quoteLineContent(L10n.SwapAndPay.fee, "\(store.feeStr) \(tokenName)")
                HStack(spacing: 0) {
                    Spacer()

                    Text(store.feeUsdStr)
                        .zFont(.medium, size: 12, style: Design.Text.tertiary)
                }
                .padding(.bottom, 12)

                Divider()
                    .frame(height: 1)
                    .background(Design.Surfaces.strokeSecondary.color(colorScheme))
                    .padding(.vertical, 12)
                
                HStack(spacing: 0) {
                    Text(L10n.SwapAndPay.totalAmount)
                        .zFont(.medium, size: 14, style: Design.Text.primary)

                    Spacer()

                    Text("\(store.totalZecToBeSpendInQuote) \(tokenName)")
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                }
                HStack(spacing: 0) {
                    Spacer()

                    Text(store.totalZecUsdToBeSpendInQuote)
                        .zFont(.medium, size: 12, style: Design.Text.tertiary)
                }
                .padding(.bottom, 32)
                
                ZashiButton(L10n.General.confirm) {
                    store.send(.confirmButtonTapped)
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
