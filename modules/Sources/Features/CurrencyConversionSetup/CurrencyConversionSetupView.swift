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
                                .fill(Design.Checkboxes.onBg.color)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .fill(Design.Checkboxes.onFg.color)
                                        .frame(width: 10, height: 10)
                                }
                        } else {
                            Circle()
                                .fill(Design.Checkboxes.offBg.color)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Circle()
                                        .stroke(Design.Checkboxes.offStroke.color)
                                        .frame(width: 20, height: 20)
                                }
                        }
                    }
                    .frame(minHeight: 40)
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Design.Surfaces.strokeSecondary.color)
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
        .padding(.horizontal, 24)
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

            primaryButton(L10n.CurrencyConversion.enable) {
                store.send(.enableTapped)
            }

            secondaryButton(L10n.CurrencyConversion.skipBtn) {
                store.send(.skipTapped)
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
                .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                .foregroundColor(
                    disabled
                    ? Design.Btns.Bold.fgDisabled.color
                    : Design.Btns.Bold.fg.color
                )
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            disabled
                            ? Design.Btns.Bold.bgDisabled.color
                            : Design.Btns.Bold.bg.color
                        )
                }
        }
        .disabled(disabled)
        .padding(.horizontal, 24)
    }
    
    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                .foregroundColor(Design.Btns.Ghost.fg.color)
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .padding(.horizontal, 24)
    }

    private func icons() -> some View {
        Asset.Assets.rateIcons.image
            .resizable()
            .frame(width: 195, height: 80)
            .offset(x: -8, y: 0)
    }
    
    private func title() -> some View {
        Text(L10n.CurrencyConversion.title)
            .font(.custom(FontFamily.Inter.semiBold.name, size: 24))
            .foregroundColor(Design.Text.primary.color)
    }
    
    private func note() -> some View {
        HStack(alignment: .top, spacing: 0) {
            Asset.Assets.infoCircle.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Design.Text.primary.color)
                .padding(.trailing, 12)

            Text(L10n.CurrencyConversion.note)
                .font(.custom(FontFamily.Inter.regular.name, size: 12))
                .foregroundColor(Design.Text.tertiary.color)
        }
        .padding(.horizontal, 24)
    }
    
    private func optionVStack(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.custom(FontFamily.Inter.semiBold.name, size: 14))
                .foregroundColor(Design.Text.primary.color)

            Text(subtitle)
                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                .foregroundColor(Design.Text.tertiary.color)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding(.trailing, 16)
    }
    
    private func optionIcon(_ icon: Image) -> some View {
        icon
            .renderingMode(.template)
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(Design.Text.primary.color)
            .padding(10)
            .background {
                Circle()
                    .fill(Design.Surfaces.bgTertiary.color)
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
                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                .foregroundColor(Design.Text.tertiary.color)
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
