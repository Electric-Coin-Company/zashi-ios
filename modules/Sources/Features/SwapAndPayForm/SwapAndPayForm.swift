//
//  SwapAndPayForm.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-26.
//

import SwiftUI
import ComposableArchitecture
import Generated

import UIComponents

public struct SwapAndPayForm: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var keyboardVisible: Bool = false
    
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
            .onAppear { observeKeyboardNotifications() }
            .applyScreenBackground()
            .zashiBack()
            .zashiTitle {
                Text(L10n.SendSelect.swapAndPay)
                    .zFont(.semiBold, size: 16, style: Design.Text.primary)
                    .fixedSize()
            }
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
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.SwapAndPay.recipientGets)
                .zFont(.medium, size: 14, style: Design.Text.secondary)
                .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                Text("100.0")
                    .zFont(.semiBold, size: 32, style: Design.Text.primary)
                    .padding(.bottom, 4)
                
                Spacer()
                
                ticker()
            }

            HStack(spacing: 0) {
                Text("$32.00")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.trailing, 4)
                
                Asset.Assets.Icons.switchHorizontal.image
                    .zImage(size: 14, style: Design.Btns.Tertiary.fg)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: Design.Radius._md)
                            .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                    }
                    .rotationEffect(Angle(degrees: 90))
                
                Spacer()

                Text("$936.25")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: Design.Radius._4xl)
                .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._4xl)
                        .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
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
                    
                    Text("1%")
                        .zFont(.semiBold, size: 14, style: Design.Btns.Primary.fg)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            }
            .frame(height: 32)
            .background {
                RoundedRectangle(cornerRadius: Design.Radius._xl)
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
                Text("100.0")
                    .zFont(.semiBold, size: 32, style: Design.Text.tertiary)
                    .padding(.bottom, 4)
                
                Spacer()
                
                ticker()
            }

            Text("$32")
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
    
    @ViewBuilder private func ticker() -> some View {
        HStack(spacing: 0) {
            Asset.Assets.Partners.coinbaseSeeklogo.image
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
                .overlay {
                    ZStack {
                        Circle()
                            .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                            .frame(width: 16, height: 16)
                            .offset(x: 6, y: 6)

                        Asset.Assets.Partners.keystoneSeekLogo.image
                            .resizable()
                            .frame(width: 14, height: 14)
                            .offset(x: 6, y: 6)
                    }
                }
            
            Text("USDT")
                .zFont(.semiBold, size: 14, style: Design.Text.primary)
                .padding(.trailing, 4)
        }
        .padding(4)
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
}
