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
    @State private var isRestoringWalletBadgeOn = false

    let store: AdvancedSettingsStore
    
    public init(store: AdvancedSettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button(L10n.Settings.recoveryPhrase.uppercased()) {
                    viewStore.send(.backupWalletAccessRequest)
                }
                .zcashStyle()
                .padding(.vertical, 25)
                .padding(.top, 40)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForBackupPhrase,
                    destination: {
                        RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForPrivateDataConsent,
                    destination: {
                        PrivateDataConsentView(store: store.privateDataConsentStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForServerSetup,
                    destination: {
                        ServerSetupView(store: store.serverSetupStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingDeleteWallet,
                    destination: {
                        DeleteWalletView(store: store.deleteWalletStore())
                    }
                )
                .onAppear {
                    isRestoringWalletBadgeOn = viewStore.isRestoringWallet
                }
                .onChange(of: viewStore.isRestoringWallet) { isRestoringWalletBadgeOn = $0 }
                .padding(.horizontal, 70)

                Button(L10n.Settings.exportPrivateData.uppercased()) {
                    viewStore.send(.updateDestination(.privateDataConsent))
                }
                .zcashStyle()
                .padding(.bottom, 25)
                .padding(.horizontal, 70)

                Button(L10n.Settings.chooseServer.uppercased()) {
                    viewStore.send(.updateDestination(.serverSetup))
                }
                .zcashStyle()
                .padding(.horizontal, 70)

                Spacer()
                
                Button(L10n.Settings.deleteZashi.uppercased()) {
                    viewStore.send(.updateDestination(.deleteWallet))
                }
                .zcashStyle()
                .padding(.bottom, 20)
                .padding(.horizontal, 70)

                Text(L10n.Settings.deleteZashiWarning)
                    .font(.custom(FontFamily.Inter.medium.name, size: 11))
                    .padding(.bottom, 50)
                    .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .zashiBack()
        .zashiTitle {
            Asset.Assets.zashiTitle.image
                .resizable()
                .frame(width: 62, height: 17)
        }
        .restoringWalletBadge(isOn: isRestoringWalletBadgeOn)
        .task { await store.send(.restoreWalletTask).finish() }
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        AdvancedSettingsView(store: .placeholder)
    }
}
