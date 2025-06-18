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

    private enum InputID: Hashable {
        case addressBookHint
    }

    @State var keyboardVisible: Bool = false
    
    @FocusState private var isAddressFocused
    @FocusState private var isAmountFocused
    @FocusState var isSlippageFocused
    
    @State var safeAreaHeight: CGFloat = 0

    @Perception.Bindable var store: StoreOf<SwapAndPay>
    let tokenName: String
    
    public init(store: StoreOf<SwapAndPay>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(spacing: 0) {
                    if store.isSwapExperienceEnabled {
                        fromView()
                            .padding(.top, 36)
                        
                        dividerView()
                        
                        toView()
                        
                        addressView()
                    } else {
                        toView()
                            .padding(.top, 36)

                        addressView()

                        dividerView()
                        
                        fromView()
                    }
                    
                    slippageView()
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    HStack(spacing: 0) {
                        Text(L10n.SwapAndPay.rate)
                            .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        
                        Spacer()
                        
                        if let rateValue = store.rateToOneZec, let selectedToken = store.selectedAsset?.token {
                            Text(L10n.SwapAndPay.oneZecRate(rateValue, selectedToken))
                                .zFont(.medium, size: 14, style: Design.Text.primary)
                        } else {
                            RoundedRectangle(cornerRadius: Design.Radius._sm)
                                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                                .shimmer(true).clipShape(RoundedRectangle(cornerRadius: 6))
                                .frame(width: 120, height: 18)
                        }
                    }
                    
                    Spacer()
                    
                    ZashiButton(L10n.Send.review) {
                        store.send(.getQuoteTapped)
                    }
                    .padding(.top, keyboardVisible ? 40 : 0)
                    .padding(.bottom, 40)
                    .disabled(!store.isValidForm)
                }
                .ignoresSafeArea()
                .frame(minHeight: keyboardVisible ? 0 : safeAreaHeight)
                .screenHorizontalPadding()
            }
            .onAppear {
                observeKeyboardNotifications()
            }
            .applyScreenBackground()
            .zashiBack()
            .zashiTitle {
                Text(L10n.SendSelect.swapAndPay)
                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                    .fixedSize()
            }
            .popover(isPresented: $store.assetSelectBinding) {
                assetContent(colorScheme)
                    .padding(.horizontal, 4)
                    .applyScreenBackground()
            }
            .overlay(
                VStack(spacing: 0) {
                    Spacer()

                    Asset.Colors.primary.color
                        .frame(height: 1)
                        .opacity(keyboardVisible ? 0.1 : 0)
                    
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
                    .overlay(
                        VStack(spacing: 0) {
                            Spacer()

                            Asset.Colors.primary.color
                                .frame(height: 1)
                                .opacity(keyboardVisible ? 0.1 : 0)
                            
                            HStack(alignment: .center) {
                                Spacer()
                                
                                Button {
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                                    to: nil, from: nil, for: nil)
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
        .onAppear {
            store.send(.onAppear)
            if let window = UIApplication.shared.windows.first {
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                safeAreaHeight = safeFrame.height
            }
        }
    }
    
    @ViewBuilder private func fromView() -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(L10n.SwapAndPay.from)
                        .zFont(.medium, size: 14, style: Design.Text.primary)
                        .padding(.bottom, 4)
                    
                    Spacer()
                    
                    Text(L10n.SwapAndPay.max(store.maxLabel))
                        .zFont(
                            .medium,
                            size: 14,
                            style: store.isInsufficientFunds
                            ? Design.Text.error
                            : Design.Text.tertiary
                        )
                }
                
                HStack(spacing: 0) {
                    zecTicker(colorScheme)
                        .frame(maxWidth: .infinity)

                    if store.isSwapExperienceEnabled {
                        HStack(spacing: 0) {
                            if store.isInputInUsd {
                                Asset.Assets.Icons.currencyDollar.image
                                    .zImage(
                                        size: 20,
                                        style: store.amountText.isEmpty
                                        ? Design.Text.tertiary
                                        : Design.Text.primary
                                    )
                            } else {
                                Asset.Assets.Icons.currencyZec.image
                                    .zImage(
                                        size: 20,
                                        style: store.amountText.isEmpty
                                        ? Design.Text.tertiary
                                        : Design.Text.primary
                                    )
                            }
                            
                            Spacer()
                            
                            TextField(
                                "",
                                text: $store.amountText,
                                prompt:
                                    Text(store.localePlaceholder)
                                    .font(.custom(FontFamily.Inter.semiBold.name, size: 24))
                                    .foregroundColor(Design.Text.primary.color(colorScheme))
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .autocapitalization(.none)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.decimalPad)
                            .zFont(.semiBold, size: 24, style: Design.Text.primary)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                            .accentColor(Design.Text.primary.color(colorScheme))
                            .focused($isAmountFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isAmountFocused = true
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: Design.Radius._lg)
                                .fill(Design.Inputs.Default.bg.color(colorScheme))
                                .background(
                                    RoundedRectangle(cornerRadius: Design.Radius._lg)
                                        .stroke(
                                            store.isInsufficientFunds
                                            ? Design.Inputs.ErrorFilled.stroke.color(colorScheme)
                                            : Design.Inputs.Default.bg.color(colorScheme)
                                        )
                                )
                        )
                    } else {
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Text(store.primaryLabelFrom)
                                .zFont(.semiBold, size: 24, style: Design.Text.tertiary)
                                .multilineTextAlignment(.trailing)
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                    }
                }
                .padding(.vertical, 8)

                HStack(spacing: 0) {
                    Spacer()

                    Text(store.secondaryLabelFrom)
                        .zFont(.medium, size: 14, style: Design.Text.tertiary)
                        .padding(.trailing, 4)
                    
                    if store.isSwapExperienceEnabled {
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
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if store.isInsufficientFunds && store.isSwapExperienceEnabled {
                HStack {
                    Spacer()
                    
                    Text(L10n.Send.Error.insufficientFunds)
                        .zFont(size: 14, style: Design.Inputs.ErrorFilled.hint)
                }
                .padding(.top, 6)
            }
        }
    }
    
    @ViewBuilder private func toView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.SwapAndPay.to)
                .zFont(.medium, size: 14, style: Design.Text.primary)
                .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        store.send(.assetSelectRequested)
                    } label: {
                        ticker(asset: store.selectedAsset, colorScheme)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)

                if store.isSwapExperienceEnabled {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Text(store.primaryLabelTo)
                            .zFont(.semiBold, size: 24, style: Design.Text.tertiary)
                            .multilineTextAlignment(.trailing)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                } else {
                    HStack(spacing: 0) {
                        if store.isInputInUsd {
                            Asset.Assets.Icons.currencyDollar.image
                                .zImage(
                                    size: 20,
                                    style: store.amountText.isEmpty
                                    ? Design.Text.tertiary
                                    : Design.Text.primary
                                )
                        }
                        
                        Spacer()
                        TextField(
                            "",
                            text: $store.amountText,
                            prompt:
                                Text(store.localePlaceholder)
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 24))
                                .foregroundColor(Design.Text.primary.color(colorScheme))
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .autocapitalization(.none)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.decimalPad)
                        .zFont(.semiBold, size: 24, style: Design.Text.primary)
                        .lineLimit(1)
                        .multilineTextAlignment(.trailing)
                        .accentColor(Design.Text.primary.color(colorScheme))
                        .focused($isAmountFocused)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: Design.Radius._lg)
                            .fill(Design.Inputs.Default.bg.color(colorScheme))
                            .background(
                                RoundedRectangle(cornerRadius: Design.Radius._lg)
                                    .stroke(
                                        store.isInsufficientFunds
                                        ? Design.Inputs.ErrorFilled.stroke.color(colorScheme)
                                        : Design.Inputs.Default.bg.color(colorScheme)
                                    )
                            )
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isAmountFocused = true
                        }
                    }
                }
            }
            .padding(.vertical, 8)

            HStack(spacing: 0) {
                Spacer()
                
                Text(store.secondaryLabelTo)
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                
                if !store.isSwapExperienceEnabled {
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
                    .padding(.leading, 4)
                }
            }

            if store.isInsufficientFunds && !store.isSwapExperienceEnabled {
                HStack {
                    Spacer()
                    
                    Text(L10n.Send.Error.insufficientFunds)
                        .zFont(size: 14, style: Design.Inputs.ErrorFilled.hint)
                }
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private func dividerView() -> some View {
        ZStack {
            Design.Utility.Gray._100.color(colorScheme)
                .frame(height: 1)
            
            Asset.Assets.Icons.arrowDown.image
                .zImage(size: 20, style: Design.Text.disabled)
                .padding(8)
                .background(Design.screenBackground.color(colorScheme))
                .rotationEffect(.degrees(store.isSwapExperienceEnabled ? 0 : 180))
        }
        .padding(.vertical, 16)
    }
    
    @ViewBuilder private func addressView() -> some View {
        ZashiTextField(
            addressFont: true,
            text: $store.address,
            placeholder: L10n.SwapAndPay.enterAddress,
            title: L10n.SwapAndPay.address,
            accessoryView:
                HStack(spacing: 4) {
                    WithPerceptionTracking {
//                                    fieldButton(
//                                        icon: store.isNotAddressInAddressBook
//                                        ? Asset.Assets.Icons.userPlus.image
//                                        : Asset.Assets.Icons.user.image
//                                    ) {
//                                        if store.isNotAddressInAddressBook {
//                                            //store.send(.addNewContactTapped(store.address))
//                                        } else {
//                                            //store.send(.addressBookTapped)
//                                        }
//                                    }
                        
                        fieldButton(icon: Asset.Assets.Icons.qr.image) {
                            store.send(.scanTapped)
                        }
                    }
                }
                .frame(height: 20)
                .offset(x: 8)
        )
        .id(InputID.addressBookHint)
        .keyboardType(.alphabet)
        .focused($isAddressFocused)
        .padding(.top, 8)
        .anchorPreference(
            key: UnknownAddressPreferenceKey.self,
            value: .bounds
        ) { $0 }
    }
    
    @ViewBuilder private func slippageView() -> some View {
        HStack(spacing: 0) {
            Text(L10n.SwapAndPay.slippage)
                .zFont(.medium, size: 14, style: Design.Text.secondary)
            
            Spacer()

            Button {
                isAmountFocused = false
                store.send(.slippageTapped)
            } label: {
                HStack(spacing: 4) {
                    Text(store.currentSlippageString)
                        .zFont(.semiBold, size: 14, style: Design.Btns.Tertiary.fg)

                    Asset.Assets.Icons.settings2.image
                        .zImage(size: 16, style: Design.Btns.Tertiary.fg)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .frame(height: 32)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._md)
                    .fill(Design.Btns.Tertiary.bg.color(colorScheme))
            }
        }
    }

    private func fieldButton(icon: Image, _ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            icon
                .zImage(size: 20, style: Design.Inputs.Default.label)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: Design.Radius._md)
                .fill(Design.Btns.Secondary.bg.color(colorScheme))
                .overlay {
                    RoundedRectangle(cornerRadius: Design.Radius._md)
                        .stroke(Design.Btns.Secondary.border.color(colorScheme))
                }
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
    
    @ViewBuilder func zecTicker(_ colorScheme: ColorScheme) -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Brandmarks.brandmarkMax.image
                .zImage(size: 24, style: Design.Text.primary)
                .padding(.trailing, 12)
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
            
            Text(tokenName)
                .zFont(.semiBold, size: 14, style: Design.Text.primary)
            
            Spacer()
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
    @ViewBuilder func noBcgTicker(asset: SwapAsset?, _ colorScheme: ColorScheme) -> some View {
        HStack(spacing: 0) {
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
                
                Text(asset.token)
                    .zFont(.semiBold, size: 14, style: Design.Text.primary)
                    .padding(.trailing, 4)
                    .fixedSize()
                    .minimumScaleFactor(0.7)
            } else {
                Circle()
                    .shimmer(true).clipShape(Circle())
                    .frame(width: 24, height: 24)
                    .zForegroundColor(Design.Surfaces.bgSecondary)
                    .padding(.trailing, 4)

                RoundedRectangle(cornerRadius: Design.Radius._sm)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                    .shimmer(true).clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(width: 50, height: 18)
                    .padding(.trailing, 4)
            }
            
            Asset.Assets.chevronDown.image
                .zImage(size: 16, style: Design.Text.primary)
                .padding(.trailing, 4)
        }
        .padding(4)
    }
    
    @ViewBuilder func ticker(asset: SwapAsset?, _ colorScheme: ColorScheme) -> some View {
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

#Preview {
    NavigationView {
        SwapAndPayForm(store: SwapAndPay.initial, tokenName: "ZEC")
    }
}

// MARK: Placeholders

extension SwapAndPay.State {
    public static var initial: Self {
        .init(
            walletBalancesState: .initial
        )
    }
}

extension SwapAndPay {
    public static var initial = StoreOf<SwapAndPay>(
        initialState: .initial
    ) {
        SwapAndPay()
    }
}
