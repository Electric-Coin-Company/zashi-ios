//
//  SwapComponents.swift
//  modules
//
//  Created by Lukáš Korba on 24.06.2025.
//

import SwiftUI
import UIComponents
import Generated
import SwapAndPay

extension TransactionDetailsView {
    @ViewBuilder func swapStatusView() -> some View {
        HStack(spacing: 0) {
            Text(L10n.SwapAndPay.status)
                .zFont(.medium, size: 14, style: Design.Text.tertiary)
            
            Spacer()
            
            if let status = store.swapStatus {
                SwapBadge(status)
            } else {
                RoundedRectangle(cornerRadius: Design.Radius._sm)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .frame(width: 72, height: 20)
            }
        }
        .screenHorizontalPadding()
    }
    
    @ViewBuilder func swapSlippageView() -> some View {
        HStack(spacing: 0) {
            Text(L10n.SwapAndPay.slippage)
                .zFont(.medium, size: 14, style: Design.Text.tertiary)
            Spacer()
            
            if let slippage = store.swapSlippage {
                Text(slippage)
                    .zFont(.medium, size: 14, style: Design.Text.primary)
                    .frame(height: 20)
            } else {
                RoundedRectangle(cornerRadius: Design.Radius._sm)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .frame(width: 86, height: 20)
            }
        }
        .screenHorizontalPadding()
    }
    
    @ViewBuilder func swapAssetsView() -> some View {
        ZStack {
            HStack(spacing: 8) {
                VStack(spacing: 4) {
                    HStack(spacing: 0) {
                        if let swapAmountIn = store.swapAmountIn {
                            Text(swapAmountIn)
                                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .frame(height: 20)

                            zecTickerLogo(colorScheme)
                                .scaleEffect(0.8)
                        } else {
                            unknownValue()

                            unknownTickerLogo(colorScheme)
                        }
                    }
                    
                    if let swapAmountInUsd = store.swapAmountInUsd {
                        Text(swapAmountInUsd)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .frame(height: 14)
                    } else {
                        unknownValue()
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                }
                
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        if let swapAmountOut = store.swapAmountOut {
                            Text(swapAmountOut)
                                .zFont(.semiBold, size: 20, style: Design.Text.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .frame(height: 20)
                        } else {
                            unknownValue()
                        }

                        if let swapDestinationAsset = store.swapDestinationAsset {
                            tokenTicker(asset: swapDestinationAsset, colorScheme)
                                .scaleEffect(0.8)
                        } else {
                            unknownTickerLogo(colorScheme)
                        }
                    }
                    
                    if let swapAmountOutUsd = store.swapAmountOutUsd {
                        Text(swapAmountOutUsd)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .frame(height: 14)
                    } else {
                        unknownValue()
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                }
            }
            
            FloatingArrow()
        }
        .screenHorizontalPadding()
    }
    
    @ViewBuilder func tokenTicker(asset: SwapAsset?, _ colorScheme: ColorScheme) -> some View {
        if let asset {
            asset.tokenIcon
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
                .overlay {
                    ZStack {
                        Circle()
                            .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                            .frame(width: 16, height: 16)
                            .offset(x: 6, y: 6)
                        
                        asset.chainIcon
                            .resizable()
                            .frame(width: 14, height: 14)
                            .offset(x: 6, y: 6)
                    }
                }
        }
    }
    
    @ViewBuilder func zecTickerLogo(_ colorScheme: ColorScheme) -> some View {
        Asset.Assets.Brandmarks.brandmarkMax.image
            .zImage(size: 24, style: Design.Text.primary)
            .padding(.trailing, 2)
            .overlay {
                Asset.Assets.Icons.shieldBcg.image
                    .zImage(size: 15, color: Design.screenBackground.color(colorScheme))
                    .offset(x: 4, y: 8)
                    .overlay {
                        Asset.Assets.Icons.shieldTickFilled.image
                            .zImage(size: 13, color: Design.Text.primary.color(colorScheme))
                            .offset(x: 4, y: 8)
                    }
            }
    }
    
    @ViewBuilder func unknownTickerLogo(_ colorScheme: ColorScheme) -> some View {
        Circle()
            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
            .frame(width: 24, height: 24)
            .overlay {
                Circle()
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .frame(width: 16, height: 16)
                    .offset(x: 8, y: 6)
                    .overlay {
                        Circle()
                            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                            .frame(width: 14, height: 14)
                            .offset(x: 8, y: 6)
                    }
            }
            .scaleEffect(0.8)
    }
    
    @ViewBuilder func unknownValue() -> some View {
        RoundedRectangle(cornerRadius: Design.Radius._sm)
            .fill(Design.Surfaces.bgTertiary.color(colorScheme))
            .frame(width: 44, height: 20)
    }
}
