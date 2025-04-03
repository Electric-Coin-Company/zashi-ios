//
//  CurrencyConversionSetupView.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-12-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct CurrencyConversionSetupView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Perception.Bindable var store: StoreOf<CurrencyConversionSetup>
    
    public init(store: StoreOf<CurrencyConversionSetup>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ScrollView {
                    if store.isSettingsView {
                        settingsLayout()
                    } else {
                        learnMoreLayout()
                    }
                }
                .padding(.vertical, 1)
                
                Spacer()
                
                if store.isSettingsView {
                    settingsFooter()
                } else {
                    learnMoreFooter()
                }
            }
            .onAppear { store.send(.onAppear) }
            .navigationBarBackButtonHidden(!store.isSettingsView)
            .zashiBackV2()
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
    
    private func settingsLayout() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header(L10n.CurrencyConversion.settingsDesc)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

            ForEach(CurrencyConversionSetup.State.SettingsOptions.allCases, id: \.self) { option in
                Button {
                    store.send(.settingsOptionTapped(option))
                } label: {
                    HStack(alignment: .top, spacing: 0) {
                        optionIcon(option.icon().image)
                        optionVStack(option.title(), subtitle: option.subtitle())
                        
                        Spacer()
                        
                        if option == store.currentSettingsOption {
                            Circle()
                                .fill(Design.Checkboxes.onBg.color(colorScheme))
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .fill(Design.Checkboxes.onFg.color(colorScheme))
                                        .frame(width: 10, height: 10)
                                }
                        } else {
                            Circle()
                                .fill(Design.Checkboxes.offBg.color(colorScheme))
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .stroke(Design.Checkboxes.offStroke.color(colorScheme))
                                        .frame(width: 20, height: 20)
                                }
                        }
                    }
                    .frame(minHeight: 40)
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 8)
    }
    
    private func learnMoreLayout() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header(L10n.CurrencyConversion.learnMoreDesc)

            ForEach(CurrencyConversionSetup.State.LearnMoreOptions.allCases, id: \.self) { option in
                HStack(alignment: .top, spacing: 0) {
                    optionIcon(option.icon().image)
                    optionVStack(option.title(), subtitle: option.subtitle())
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 12)
        }
        .screenHorizontalPadding()
    }
 
    private func settingsFooter() -> some View {
        VStack {
            note()
                .padding(.bottom, 20)
            
            primaryButton(L10n.CurrencyConversion.saveBtn, disabled: store.isSaveButtonDisabled) {
                store.send(.saveChangesTapped)
            }
        }
        .padding(.bottom, 24)
    }
    
    private func learnMoreFooter() -> some View {
        VStack {
            note()
                .padding(.bottom, 20)

            secondaryButton(L10n.CurrencyConversion.skipBtn) {
                store.send(.skipTapped)
            }
            
            primaryButton(L10n.CurrencyConversion.enable) {
                store.send(.enableTapped)
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - UI components

extension CurrencyConversionSetupView {
    private func primaryButton(
        _ title: String,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .zFont(.semiBold, size: 16,
                       style: disabled
                       ? Design.Btns.Primary.fgDisabled
                       : Design.Btns.Primary.fg
                )
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            disabled
                            ? Design.Btns.Primary.bgDisabled.color(colorScheme)
                            : Design.Btns.Primary.bg.color(colorScheme)
                        )
                }
        }
        .disabled(disabled)
        .screenHorizontalPadding()
    }
    
    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .zFont(.semiBold, size: 16, style: Design.Btns.Ghost.fg)
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .screenHorizontalPadding()
    }

    private func icons() -> some View {
        Asset.Assets.rateIcons.image
            .resizable()
            .frame(width: 195, height: 80)
            .offset(x: -8, y: 0)
    }
    
    private func title() -> some View {
        Text(L10n.CurrencyConversion.title)
            .zFont(.semiBold, size: 24, style: Design.Text.primary)
    }
    
    private func note() -> some View {
        HStack(alignment: .top, spacing: 0) {
            Asset.Assets.infoCircle.image
                .zImage(size: 20, style: Design.Text.primary)
                .padding(.trailing, 12)

            Text(L10n.CurrencyConversion.note)
                .zFont(size: 12, style: Design.Text.tertiary)
        }
        .screenHorizontalPadding()
    }
    
    private func optionVStack(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .zFont(.semiBold, size: 14, style: Design.Text.primary)

            Text(subtitle)
                .zFont(size: 14, style: Design.Text.tertiary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding(.trailing, 16)
    }
    
    private func optionIcon(_ icon: Image) -> some View {
        icon
            .zImage(size: 20, style: Design.Text.primary)
            .padding(10)
            .background {
                Circle()
                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
            }
            .padding(.trailing, 16)
    }
    
    private func header(_ desc: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                icons()
                    .padding(.vertical, 24)
                
                Spacer()
            }
            
            title()
                .padding(.bottom, 8)
            
            Text(desc)
                .zFont(size: 14, style: Design.Text.tertiary)
                .padding(.bottom, 4)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        CurrencyConversionSetupView(store: CurrencyConversionSetup.initial)
    }
}

// MARK: - Store

extension CurrencyConversionSetup {
    public static var initial = StoreOf<CurrencyConversionSetup>(
        initialState: .init(isSettingsView: false)
    ) {
        CurrencyConversionSetup()
    }
}

// MARK: - Placeholders

extension CurrencyConversionSetup.State {
    public static let initial = CurrencyConversionSetup.State()
}
