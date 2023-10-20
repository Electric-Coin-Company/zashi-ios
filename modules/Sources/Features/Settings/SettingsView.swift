import SwiftUI
import ComposableArchitecture
import Generated
import RecoveryPhraseDisplay
import UIComponents

public struct SettingsView: View {
    @Environment(\.openURL) var openURL

    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(L10n.Settings.recoveryPhrase.uppercased()) {
                    viewStore.send(.backupWalletAccessRequest)
                }
                .zcashStyle()
                .padding(.vertical, 25)

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
                    // https://github.com/zcash/secant-ios-wallet/issues/866
                }
                .zcashStyle()

                Spacer()
                
                Button(L10n.Settings.about.uppercased()) {
                    viewStore.send(.updateDestination(.about))
                }
                .zcashStyle()
                .padding(.bottom, 50)
            }
            .applyScreenBackground()
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
            .onAppear { viewStore.send(.onAppear) }

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
        }
        .padding(.horizontal, 70)
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
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        SettingsView(store: .placeholder)
    }
}
