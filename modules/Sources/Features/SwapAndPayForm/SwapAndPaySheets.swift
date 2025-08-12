//
//  SwapAndPaySheets.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-26.
//

import UIKit
import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import SwapAndPay

import BalanceBreakdown

extension SwapAndPayForm {
    @ViewBuilder func assetsLoadingComposition(_ colorScheme: ColorScheme) -> some View {
        List {
            WithPerceptionTracking {
                ForEach(0..<15) { _ in
                    NoTransactionPlaceholder(true)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.background.color)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .disabled(true)
        .padding(.vertical, 1)
        .background(Asset.Colors.background.color)
        .listStyle(.plain)
    }
    
    @ViewBuilder func assetsEmptyComposition(_ colorScheme: ColorScheme) -> some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        NoTransactionPlaceholder()
                    }
                    
                    Spacer()
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .clear, location: 0.0),
                            Gradient.Stop(color: Asset.Colors.background.color, location: 0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                
                VStack(spacing: 0) {
                    Asset.Assets.Illustrations.emptyState.image
                        .resizable()
                        .frame(width: 164, height: 164)
                        .padding(.bottom, 20)
                    
                    Text(L10n.SwapAndPay.EmptyAssets.title)
                        .zFont(.semiBold, size: 20, style: Design.Text.primary)
                        .padding(.bottom, 8)
                    
                    Text(L10n.SwapAndPay.EmptyAssets.subtitle)
                        .zFont(size: 14, style: Design.Text.tertiary)
                        .padding(.bottom, 20)
                }
                .padding(.top, 40)
            }
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
                .padding(.bottom, 32)
                .padding(.horizontal, 20)
                
                if store.swapAssetsToPresent.isEmpty && !store.searchTerm.isEmpty {
                    assetsEmptyComposition(colorScheme)
                } else if store.swapAssetsToPresent.isEmpty && store.searchTerm.isEmpty {
                    assetsLoadingComposition(colorScheme)
                } else {
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
                                        .offset(x: 9, y: 16)
                                    
                                    asset.chainIcon
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .offset(x: 9, y: 16)
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
//            ScrollView {
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
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 0) {
                        slippageChip(index: 0, text: store.slippage05String, colorScheme)
                        slippageChip(index: 1, text: store.slippage1String, colorScheme)
                        slippageChip(index: 2, text: store.slippage2String, colorScheme)
                        
                        if store.selectedSlippageChip == 3 {
                            HStack(spacing: 0) {
                                Spacer()
                                
                                FocusableTextField(
                                    text: $store.customSlippage,
                                    isFirstResponder: $isSlippageFocused,
                                    placeholder: "%",
                                    colorScheme: colorScheme
                                )
                                .multilineTextAlignment(.center)
                                .frame(maxWidth:
                                    store.customSlippage.isEmpty
                                       ? .infinity
                                       : (store.customSlippage.contains(".") || store.customSlippage.contains(","))
                                       ? CGFloat(store.customSlippage.count - 1) * 13.0 + 2.0
                                       : CGFloat(store.customSlippage.count) * 13.0
                                )
                                .keyboardType(.decimalPad)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
                        if store.slippageInSheet > 30.0 {
                            Text(L10n.SwapAndPay.maxAllowedSlippage1)
                            + Text(L10n.SwapAndPay.maxAllowedSlippage2(Constants.maxAllowedSlippage)).bold()
                        } else if let slippageDiff = store.slippageDiff {
                            Text(L10n.SwapAndPay.slippageSet1)
                            + Text(
                                L10n.SwapAndPay.slippageSet2a(
                                    store.currentSlippageInSheetString,
                                    slippageDiff
                                )
                            ).bold()
                            + Text(L10n.SwapAndPay.slippageSet3)
                        } else {
                            Text(L10n.SwapAndPay.slippageSet1)
                            + Text(L10n.SwapAndPay.slippageSet2b(store.currentSlippageInSheetString)).bold()
                            + Text(L10n.SwapAndPay.slippageSet3)
                        }
                    }
                    .zFont(size: 12, style: slippageWarnTextStyle())
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._lg)
                            .fill(slippageWarnBcgColor(colorScheme))
                    }
                    .padding(.vertical, 20)

                    Spacer()
                    
                    ZashiButton(L10n.General.confirm) {
                        store.send(.slippageSetConfirmTapped)
                    }
                    .padding(.bottom, keyboardVisible ? 74 : 36)
                    .disabled(store.slippageInSheet > 30.0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.vertical, 1)
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
                    
                    FloatingArrow()
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

                quoteLineContent(
                    L10n.SwapAndPay.providerFee,
                    "\(store.swapProviderFeeZECStr) \(tokenName)"
                )
                .padding(.top, 12)
                HStack(spacing: 0) {
                    Spacer()
                    
                    Text(store.swapProviderFeeUsdStr)
                        .zFont(.medium, size: 12, style: Design.Text.tertiary)
                }
                
                if !store.isSwapExperienceEnabled {
                    quoteLineContent(
                        L10n.SwapAndPay.maxSlippage(store.currentSlippageString),
                        "\(store.swapSlippageStr) \(tokenName)"
                    )
                    .padding(.top, 12)
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Text(store.swapSlippageUsdStr)
                            .zFont(.medium, size: 12, style: Design.Text.tertiary)
                    }
                }
                
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
                
                if store.isSwapExperienceEnabled {
                    HStack(alignment: .top, spacing: 0) {
                        Asset.Assets.infoOutline.image
                            .zImage(size: 16, style: Design.Text.tertiary)
                            .padding(.trailing, 12)
                        
                        Text(L10n.SwapAndPay.swapQuoteSlippageWarn(store.swapQuoteSlippageUsdStr, store.currentSlippageString))
                    }
                    .zFont(size: 12, style: Design.Text.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }

                if store.selectedWalletAccount?.vendor == .keystone {
                    ZashiButton(L10n.Keystone.confirm) {
                        store.send(.confirmWithKeystoneTapped)
                    }
                    .padding(.bottom, 24)
                } else {
                    ZashiButton(L10n.General.confirm) {
                        store.send(.confirmButtonTapped)
                    }
                    .padding(.bottom, 24)
                }
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
    
    @ViewBuilder func cancelSheetContent(_ colorScheme: ColorScheme) -> some View {
        VStack(spacing: 0) {
            Asset.Assets.Icons.logOut.image
                .zImage(size: 20, style: Design.Utility.ErrorRed._500)
                .background {
                    Circle()
                        .fill(Design.Utility.ErrorRed._100.color(colorScheme))
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 48)
                .padding(.bottom, 20)

            Text(L10n.SwapAndPay.canceltitle)
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.bottom, 8)

            Text(L10n.SwapAndPay.cancelMsg)
                .zFont(size: 14, style: Design.Text.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            ZashiButton(
                L10n.SwapAndPay.cancelSwap,
                type: .destructive1
            ) {
                store.send(.cancelSwapTapped)
            }
            .padding(.bottom, 8)
            
            ZashiButton(L10n.SwapAndPay.cancelDont) {
                store.send(.dontCancelTapped)
            }
            .padding(.bottom, 24)
        }
    }
}

struct FocusableTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var placeholder: String = ""
    let colorScheme: ColorScheme

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor(Design.Switcher.selectedText.color(colorScheme)),
                .font: FontFamily.Inter.medium.font(size: 16)
            ]
        )
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.keyboardType = .decimalPad
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        textField.font = FontFamily.Inter.medium.font(size: 16)
        textField.textColor = UIColor(Design.Switcher.selectedText.color(colorScheme))

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text

        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFirstResponder: $isFirstResponder)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFirstResponder: Bool

        init(text: Binding<String>, isFirstResponder: Binding<Bool>) {
            _text = text
            _isFirstResponder = isFirstResponder
        }

        @objc func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFirstResponder = true
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isFirstResponder = false
        }
    }
}
