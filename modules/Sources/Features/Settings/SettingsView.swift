import SwiftUI
import ComposableArchitecture
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent

public struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var isRestoringWalletBadgeOn = false

    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button(L10n.Settings.recoveryPhrase.uppercased()) {
                    viewStore.send(.backupWalletAccessRequest)
                }
                .zcashStyle()
                .padding(.vertical, 25)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForBackupPhrase,
                    destination: {
                        RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAbout,
                    destination: {
                        About(store: store)
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForPrivateDataConsent,
                    destination: {
                        PrivateDataConsentView(store: store.privateDataConsentStore())
                    }
                )
                .onAppear {
                    viewStore.send(.onAppear)
                    isRestoringWalletBadgeOn = viewStore.isRestoringWallet
                }
                .onChange(of: viewStore.isRestoringWallet) { isRestoringWalletBadgeOn = $0 }

                if let supportData = viewStore.supportData {
                    UIMailDialogView(
                        supportData: supportData,
                        completion: {
                            viewStore.send(.sendSupportMailFinished)
                        }
                    )
                    // UIMailDialogView only wraps MFMailComposeViewController presentation
                    // so frame is set to 0 to not break SwiftUIs layout
                    .frame(width: 0, height: 0)
                }
                
                Button(L10n.Settings.feedback.uppercased()) {
                    viewStore.send(.sendSupportMail)
                }
                .zcashStyle()
                .padding(.bottom, 25)
                
                Button(L10n.Settings.privacyPolicy.uppercased()) {
                    if let url = URL(string: "https://z.cash/privacy-policy/") {
                        openURL(url)
                    }
                }
                .zcashStyle()
                .padding(.bottom, 25)
                
                Button(L10n.Settings.documentation.uppercased()) {
                    // TODO: - [#866] finish the documentation button action
                    // https://github.com/Electric-Coin-Company/zashi-ios/issues/866
                }
                .zcashStyle()
                .padding(.bottom, 25)
                
                Button(L10n.Settings.exportPrivateData.uppercased()) {
                    viewStore.send(.updateDestination(.privateDataConsent))
                }
                .zcashStyle()
                .padding(.bottom, 80)

                Button(L10n.Settings.about.uppercased()) {
                    viewStore.send(.updateDestination(.about))
                }
                .zcashStyle()
            }
            .padding(.horizontal, 70)
        }
        .padding(.vertical, 1)
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
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
        SettingsView(store: .placeholder)
    }
}
