//
//  SwapAndPayForm.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-26.
//

import SwiftUI
import ComposableArchitecture
import Generated
import SwapAndPay

import UIComponents

public struct SwapAndPayForm: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var keyboardVisible: Bool = false
    
    @FocusState private var isAmountFocused
    @FocusState var isSlippageFocused

    @Perception.Bindable var store: StoreOf<SwapAndPay>
    let tokenName: String
    
    public init(store: StoreOf<SwapAndPay>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                recipientGetsView()
                    .padding(.top, 24)

                slippageView()
                
                youPayView()
                
                Spacer()
                
                ZashiButton(L10n.SwapAndPay.getQuote) {
                    store.send(.getQuoteTapped)
                }
                .padding(.bottom, 24)
            }
            .screenHorizontalPadding()
            .onAppear {
                observeKeyboardNotifications()
                isAmountFocused = true
            }
            .applyScreenBackground()
            .zashiBack()
            .zashiTitle {
                Text(L10n.SendSelect.swapAndPay)
                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                    .fixedSize()
            }
            .overlay(
                VStack(spacing: 0) {
                    Spacer()

                    Asset.Colors.primary.color
                        .frame(height: 1)
                        .opacity(0.1)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Button {
                            isAmountFocused = false
                        } label: {
                            Text(L10n.General.done.uppercased())
                                .zFont(.regular, size: 14, style: Design.Text.primary)
                        }
                        .padding(.bottom, 4)
                    }
                    .applyScreenBackground()
                    .padding(.horizontal, 20)
                    .frame(height: keyboardVisible ? 38 : 0)
                    .frame(maxWidth: .infinity)
                    .opacity(keyboardVisible ? 1 : 0)
                }
            )
            .popover(isPresented: $store.isSlippagePresented) {
                slippageContent(colorScheme)
                    .screenHorizontalPadding()
                    .applyScreenBackground()
            }
            .zashiSheet(isPresented: $store.isQuotePresented) {
                quoteContent(colorScheme)
                    .screenHorizontalPadding()
                    .applyScreenBackground()
            }
            .zashiSheet(isPresented: $store.isQuoteUnavailablePresented) {
                quoteUnavailableContent(colorScheme)
                    .screenHorizontalPadding()
                    .applyScreenBackground()
            }
        }
    }
    
    @ViewBuilder private func recipientGetsView() -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.SwapAndPay.recipientGets)
                    .zFont(.medium, size: 14, style: Design.Text.secondary)
                    .padding(.bottom, 4)
                
                HStack(spacing: 0) {
                    if store.isInputInUsd {
                        Asset.Assets.Icons.currencyDollar.image
                            .zImage(size: 26, style: Design.Inputs.Default.text)
                    }
                    
                    TextField(
                        "",
                        text: $store.amountText,
                        prompt:
                            Text(store.localePlaceholder)
                            .font(.custom(FontFamily.Inter.semiBold.name, size: 32))
                            .foregroundColor(Design.Text.primary.color(colorScheme))
                    )
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.decimalPad)
                    .zFont(.semiBold, size: 32, style: Design.Text.primary)
                    .lineLimit(1)
                    .accentColor(Design.Text.primary.color(colorScheme))
                    .padding(.bottom, 4)
                    .focused($isAmountFocused)
                    
                    Spacer()
                    
                    if let asset = store.selectedAsset {
                        ticker(asset: asset, colorScheme)
                    }
                }
                
                HStack(spacing: 0) {
                    Text(store.recipientGetsConverted)
                        .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        .padding(.trailing, 4)
                    
                    Button {
                        store.send(.switchInputTapped)
                    } label: {
                        Asset.Assets.Icons.switchHorizontal.image
                            .zImage(size: 14, style: Design.Btns.Tertiary.fg)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: Design.Radius._md)
                                    .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                            }
                            .rotationEffect(Angle(degrees: 90))
                    }
                    
                    Spacer()
                    
                    Text(store.spendableUSDBalance)
                        .zFont(
                            .medium,
                            size: 14,
                            style: store.isInsufficientFunds
                            ? Design.Text.error
                            : Design.Text.tertiary
                        )
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._4xl)
                    .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._4xl)
                            .stroke(
                                store.isInsufficientFunds
                                ? Design.Text.error.color(colorScheme)
                                : Design.Surfaces.strokeSecondary.color(colorScheme)
                            )
                    }
            }
            
            if store.isInsufficientFunds {
                HStack {
                    Spacer()
                    
                    Text(L10n.Send.Error.insufficientFunds)
                        .zFont(size: 14, style: Design.Inputs.ErrorFilled.hint)
                }
                .padding(.top, 6)
            }
        }
    }

    @ViewBuilder private func slippageView() -> some View {
        HStack(spacing: 0) {
            Design.Utility.Gray._100.color(colorScheme)
                .frame(width: 1)
                .padding(.horizontal, 20)
            
            Text(L10n.SwapAndPay.slippage)
                .zFont(.medium, size: 14, style: Design.Text.secondary)
            
            Spacer()

            Button {
                store.send(.slippageTapped)
            } label: {
                HStack(spacing: 0) {
                    Asset.Assets.Icons.slippage.image
                        .zImage(size: 16, style: Design.Btns.Primary.fg)
                        .padding(.trailing, 4)
                    
                    Text(String(format: "%0.1f%%", store.slippage * 0.1))
                        .zFont(.semiBold, size: 14, style: Design.Btns.Primary.fg)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .frame(height: 32)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._md)
                    .fill(Design.Btns.Primary.bg.color(colorScheme))
            }
        }
        .frame(height: 32)
        .padding(.vertical, 12)
    }

    @ViewBuilder private func youPayView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.SwapAndPay.youPay)
                .zFont(.medium, size: 14, style: Design.Text.secondary)
                .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                Text(store.youPayZec)
                    .zFont(.semiBold, size: 32, style: Design.Text.tertiary)
                    .padding(.bottom, 4)
                    .fixedSize()
                    .minimumScaleFactor(0.7)
                
                Spacer()

                if let asset = store.zecAsset {
                    ticker(asset: asset, colorScheme)
                }
            }

            Text(store.youPayZecConverted)
                .zFont(.medium, size: 14, style: Design.Text.tertiary)
                .padding(.bottom, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Design.Radius._4xl)
                .fill(Design.Utility.Gray._50.color(colorScheme))
        }
    }

    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = true
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                keyboardVisible = false
            }
        }
    }
    
    public func slippageWarnBcgColor(_ colorScheme: ColorScheme) -> Color {
        if store.slippageInSheet <= 10.0 {
            return Design.Utility.Gray._50.color(colorScheme)
        } else if store.slippageInSheet > 10.0 && store.slippageInSheet < 30.0 {
            return Design.Utility.WarningYellow._50.color(colorScheme)
        } else {
            return Design.Utility.ErrorRed._50.color(colorScheme)
        }
    }
    
    public func slippageWarnIconColor(_ colorScheme: ColorScheme) -> Color {
        if store.slippageInSheet <= 10.0 {
            return Design.Utility.Gray._600.color(colorScheme)
        } else if store.slippageInSheet > 10.0 && store.slippageInSheet < 30.0 {
            return Design.Utility.WarningYellow._600.color(colorScheme)
        } else {
            return Design.Utility.ErrorRed._600.color(colorScheme)
        }
    }
    
    public func slippageWarnTextStyle() -> Colorable {
        if store.slippageInSheet <= 10.0 {
            return Design.Utility.Gray._900
        } else if store.slippageInSheet > 10.0 && store.slippageInSheet < 30.0 {
            return Design.Utility.WarningYellow._900
        } else {
            return Design.Utility.ErrorRed._900
        }
    }
}

extension View {
    @ViewBuilder func noBcgTicker(asset: SwapAsset, _ colorScheme: ColorScheme) -> some View {
        HStack(spacing: 0) {
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
            
            Text(asset.token)
                .zFont(.semiBold, size: 14, style: Design.Text.primary)
                .padding(.trailing, 4)
                .fixedSize()
                .minimumScaleFactor(0.7)
        }
        .padding(4)
    }
    
    @ViewBuilder func ticker(asset: SwapAsset, _ colorScheme: ColorScheme) -> some View {
        noBcgTicker(asset: asset, colorScheme)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._full)
                    .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._full)
                            .stroke(Design.Surfaces.strokeTertiary.color(colorScheme))
                    }
            }
            .shadow(color: .black.opacity(0.02), radius: 0.66667, x: 0, y: 1.33333)
            .shadow(color: .black.opacity(0.08), radius: 1.33333, x: 0, y: 1.33333)
    }
}
