//
//  SwapAndPayOptInView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-30.
//

import SwiftUI
import ComposableArchitecture
import Generated
import SwapAndPay

import UIComponents

public struct SwapAndPayOptInView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<SwapAndPay>

    public init(store: StoreOf<SwapAndPay>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ScrollView {
                    layout()
                }
                .padding(.vertical, 1)
                
                Spacer()
                
                HStack(alignment: .top, spacing: 0) {
                    Asset.Assets.infoCircle.image
                        .zImage(size: 20, style: Design.Text.primary)
                        .padding(.trailing, 12)

                    Text(L10n.SwapAndPay.OptIn.warn)
                        .zFont(size: 12, style: Design.Text.tertiary)
                }
                .padding(.bottom, 20)
                
                ZashiButton(
                    L10n.CurrencyConversion.skipBtn,
                    type: .ghost
                ) {
                    store.send(.skipOptInTapped)
                }
                .padding(.bottom, 12)

                ZashiButton(L10n.General.confirm) {
                    store.send(.confirmOptInTapped)
                }
                .padding(.bottom, 24)
                .disabled(!store.optionOneChecked || !store.optionTwoChecked)
            }
        }
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
    
    private func header() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Asset.Assets.Brandmarks.brandmarkMax.image
                    .zImage(size: 64, style: Design.Surfaces.brandPrimary)

                ZStack {
                    Asset.Assets.Tickers.nearChain.image
                        .zImage(size: 70, color: Design.screenBackground.color(colorScheme))
                        .offset(x: -10)

                    Asset.Assets.Tickers.nearChain.image
                        .resizable()
                        .frame(width: 64, height: 64)
                        .offset(x: -10)
                }

                Spacer()
            }
            .padding(.vertical, 24)

            HStack(spacing: 6) {
                Text(L10n.SwapAndPay.OptIn.title)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.bottom, 8)
                
                Asset.Assets.Partners.nearLogo.image
                    .zImage(width: 98, height: 24, style: Design.Text.primary)
                    .offset(y: -4)
            }
            
            Text(L10n.SwapAndPay.OptIn.desc)
                .zFont(size: 14, style: Design.Text.tertiary)
                .padding(.bottom, 4)
        }
    }
    
    private func layout() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header()
                .padding(.bottom, 24)

            Button {
                store.send(.optionOneTapped)
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    ZashiToggle(isOn: $store.optionOneChecked)
                        .padding(.trailing, 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.SwapAndPay.OptIn.optionOneTitle)
                            .zFont(.semiBold, size: 14, style: Design.Text.primary)
                        
                        Text(L10n.SwapAndPay.OptIn.optionOneSubtitle)
                            .zFont(size: 14, style: Design.Text.tertiary)
                    }
                    
                    Spacer()
                }
                .frame(minHeight: 40)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                        .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                }
            }
            .padding(.bottom, 12)

            Button {
                store.send(.optionTwoTapped)
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    ZashiToggle(isOn: $store.optionTwoChecked)
                        .padding(.trailing, 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.SwapAndPay.OptIn.optionTwoTitle)
                            .zFont(.semiBold, size: 14, style: Design.Text.primary)
                        
                        Text(L10n.SwapAndPay.OptIn.optionTwoSubtitle)
                            .zFont(size: 14, style: Design.Text.tertiary)
                    }
                    
                    Spacer()
                }
                .frame(minHeight: 40)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: Design.Radius._xl)
                        .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                }
            }
            .padding(.bottom, 12)
        }
    }
}
