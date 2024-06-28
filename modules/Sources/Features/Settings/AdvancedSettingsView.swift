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

public struct AdvancedSettingsView: View {
    @Perception.Bindable var store: StoreOf<AdvancedSettings>
    
    public init(store: StoreOf<AdvancedSettings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                Button(L10n.Settings.recoveryPhrase.uppercased()) {
                    store.send(.protectedAccessRequest(.backupPhrase))
                }
                .zcashStyle()
                .padding(.vertical, 25)
                .padding(.top, 40)
                .padding(.horizontal, 70)
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

                Button(L10n.Settings.exportPrivateData.uppercased()) {
                    store.send(.protectedAccessRequest(.privateDataConsent))
                }
                .zcashStyle()
                .padding(.bottom, 25)
                .padding(.horizontal, 70)

                Button(L10n.Settings.chooseServer.uppercased()) {
                    store.send(.updateDestination(.serverSetup))
                }
                .zcashStyle()
                .padding(.bottom, 25)
                .padding(.horizontal, 70)

                if store.inAppBrowserURL != nil {
                    Button("Buy ZEC".uppercased()) {
                        store.send(.buyZecTapped)
                    }
                    .zcashStyle()
                    .padding(.horizontal, 70)
                }

                Spacer()
                
                Button(L10n.Settings.deleteZashi.uppercased()) {
                    store.send(.protectedAccessRequest(.deleteWallet))
                }
                .zcashStyle()
                .padding(.bottom, 20)
                .padding(.horizontal, 70)

                Text(L10n.Settings.deleteZashiWarning)
                    .font(.custom(FontFamily.Inter.medium.name, size: 11))
                    .padding(.bottom, 50)
                    .padding(.horizontal, 20)
            }
            .walletStatusPanel()
            .sheet(isPresented: $store.isInAppBrowserOn) {
                if let urlStr = store.inAppBrowserURL, let url = URL(string: urlStr) {
                    InAppBrowserView(url: url)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .zashiBack()
        .zashiTitle {
            Asset.Assets.zashiTitle.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 62, height: 17)
                .foregroundColor(Asset.Colors.primary.color)
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
            state: \.deleteWallet,
            action: \.deleteWallet
        )
    }
}

// MARK: Placeholders

extension AdvancedSettings.State {
    public static let initial = AdvancedSettings.State(
        deleteWallet: .initial,
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
            deleteWallet: .initial,
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
