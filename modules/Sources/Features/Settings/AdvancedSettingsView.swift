//
//  AdvancedSettingsView.swift
//
//
//  Created by Lukáš Korba on 2024-02-12.
//

import SwiftUI
import ComposableArchitecture

import DeleteWallet
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup
import CurrencyConversionSetup

public struct AdvancedSettingsView: View {
    @Perception.Bindable var store: StoreOf<AdvancedSettings>
    
    public init(store: StoreOf<AdvancedSettings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                List {
                    Group {
                        SettingsRow(
                            icon: Asset.Assets.Icons.key.image,
                            title: L10n.Settings.recoveryPhrase
                        ) {
                            store.send(.protectedAccessRequest(.backupPhrase))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.Icons.downloadCloud.image,
                            title: L10n.Settings.exportPrivateData
                        ) {
                            store.send(.protectedAccessRequest(.privateDataConsent))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.Icons.server.image,
                            title: L10n.Settings.chooseServer
                        ) {
                            store.send(.updateDestination(.serverSetup))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.Icons.currencyDollar.image,
                            title: L10n.CurrencyConversion.title
                        ) {
                            store.send(.updateDestination(.currencyConversionSetup))
                        }
                        
                        if store.inAppBrowserURL != nil {
                            SettingsRow(
                                icon: Asset.Assets.Icons.coinbase.image,
                                iconTint: Asset.Colors.Settings.coinbaseTint.color,
                                iconBcg: Asset.Colors.Settings.coinbaseBcg.color,
                                title: L10n.Settings.buyZecCB,
                                divider: false
                            ) {
                                store.send(.buyZecTapped)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .walletStatusPanel()
                .sheet(isPresented: $store.isInAppBrowserOn) {
                    if let urlStr = store.inAppBrowserURL, let url = URL(string: urlStr) {
                        InAppBrowserView(url: url)
                    }
                }
                .onAppear { store.send(.onAppear) }
                .navigationLinkEmpty(
                    isActive: store.bindingForBackupPhrase,
                    destination: {
                        RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingForPrivateDataConsent,
                    destination: {
                        PrivateDataConsentView(store: store.privateDataConsentStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingForServerSetup,
                    destination: {
                        ServerSetupView(store: store.serverSetupStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingDeleteWallet,
                    destination: {
                        DeleteWalletView(store: store.deleteWalletStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingCurrencyConversionSetup,
                    destination: {
                        CurrencyConversionSetupView(store: store.currencyConversionSetupStore())
                    }
                )
                
                Spacer()

                HStack(spacing: 0) {
                    Asset.Assets.infoOutline.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 12)

                    Text(L10n.Settings.deleteZashiWarning)
                        .font(.custom(FontFamily.Inter.regular.name, size: 12))
                }
                .foregroundColor(Design.Text.tertiary.color)
                .padding(.bottom, 20)

                Button {
                    store.send(.protectedAccessRequest(.deleteWallet))
                } label: {
                    Text(L10n.Settings.deleteZashi)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                        .foregroundColor(Design.Btns.Destructive1.fg.color)
                        .frame(height: 24)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Design.Btns.Destructive1.bg.color)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Design.Btns.Destructive1.border.color)
                                }
                        }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .zashiTitle {
            Text(L10n.Settings.advanced.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        AdvancedSettingsView(store: .initial)
    }
}

// MARK: - ViewStore
extension StoreOf<AdvancedSettings> {
    var destinationBinding: Binding<AdvancedSettings.State.Destination?> {
        Binding {
            self.state.destination
        } set: {
            self.send(.updateDestination($0))
        }
    }
    
    var bindingForBackupPhrase: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .backupPhrase },
            embed: { $0 ? .backupPhrase : nil }
        )
    }
    
    var bindingForPrivateDataConsent: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .privateDataConsent },
            embed: { $0 ? .privateDataConsent : nil }
        )
    }
    
    var bindingForServerSetup: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .serverSetup },
            embed: { $0 ? .serverSetup : nil }
        )
    }
    
    var bindingDeleteWallet: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .deleteWallet },
            embed: { $0 ? .deleteWallet : nil }
        )
    }

    var bindingCurrencyConversionSetup: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .currencyConversionSetup },
            embed: { $0 ? .currencyConversionSetup : nil }
        )
    }

    func backupPhraseStore() -> StoreOf<RecoveryPhraseDisplay> {
        self.scope(
            state: \.phraseDisplayState,
            action: \.phraseDisplay
        )
    }
    
    func privateDataConsentStore() -> PrivateDataConsentStore {
        self.scope(
            state: \.privateDataConsentState,
            action: \.privateDataConsent
        )
    }
    
    func serverSetupStore() -> StoreOf<ServerSetup> {
        self.scope(
            state: \.serverSetupState,
            action: \.serverSetup
        )
    }
    
    func deleteWalletStore() -> StoreOf<DeleteWallet> {
        self.scope(
            state: \.deleteWalletState,
            action: \.deleteWallet
        )
    }
    
    func currencyConversionSetupStore() -> StoreOf<CurrencyConversionSetup> {
        self.scope(
            state: \.currencyConversionSetupState,
            action: \.currencyConversionSetup
        )
    }
}

// MARK: Placeholders

extension AdvancedSettings.State {
    public static let initial = AdvancedSettings.State(
        currencyConversionSetupState: .init(isSettingsView: true),
        deleteWalletState: .initial,
        phraseDisplayState: RecoveryPhraseDisplay.State(
            phrase: nil,
            showBackButton: false,
            birthday: nil
        ),
        privateDataConsentState: .initial,
        serverSetupState: ServerSetup.State()
    )
}

extension StoreOf<AdvancedSettings> {
    public static let initial = StoreOf<AdvancedSettings>(
        initialState: .initial
    ) {
        AdvancedSettings()
    }

    public static let demo = StoreOf<AdvancedSettings>(
        initialState: .init(
            currencyConversionSetupState: .initial,
            deleteWalletState: .initial,
            phraseDisplayState: RecoveryPhraseDisplay.State(
                phrase: nil,
                birthday: nil
            ),
            privateDataConsentState: .initial,
            serverSetupState: ServerSetup.State()
        )
    ) {
        AdvancedSettings()
    }
}
