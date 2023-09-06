import SwiftUI
import ComposableArchitecture
import Generated
import RecoveryPhraseDisplay
import UIComponents
import ExportLogs

public struct SettingsView: View {
    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 25) {
            
                Button(
                    action: { viewStore.send(.backupWalletAccessRequest) },
                    label: { Text(L10n.Settings.backupWallet.uppercased()) }
                )
                .activeButtonStyle
                .frame(height: 70)
                
                Button(
                    action: { viewStore.send(.sendSupportMail) },
                    label: { Text(L10n.Settings.feedback.uppercased()) }
                )
                .activeButtonStyle
                .frame(height: 70)
                
                Button(
                    action: { viewStore.send(.privacyPolicy) },
                    label: { Text(L10n.Settings.privacyPolicy.uppercased()) }
                )
                .activeButtonStyle
                .frame(height: 70)
                
                Button(
                    action: { viewStore.send(.documentation) },
                    label: { Text(L10n.Settings.documentation.uppercased()) }
                )
                .activeButtonStyle
                .frame(height: 70)
                
                Spacer()
                
                Button(
                    action: { viewStore.send(.updateDestination(.about)) },
                    label: { Text(L10n.Settings.about.uppercased()) }
                )
                .activeButtonStyle
                .frame(maxHeight: 50)
                .padding(.bottom, 50)
            }
            .padding(EdgeInsets(top: 30.0, leading: 50.0, bottom: 0, trailing: 50.0))
            .padding(.horizontal, 30)
            .navigationTitle(L10n.Settings.title.uppercased())
            .replaceNavigationBackButton()
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

            shareLogsView(viewStore)

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
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
        .alert(store: store.scope(
            state: \.exportLogsState.$alert,
            action: { .exportLogs(.alert($0)) }
        ))
    }

    @ViewBuilder func shareLogsView(_ viewStore: SettingsViewStore) -> some View {
        if viewStore.exportLogsState.isSharingLogs {
            UIShareDialogView(
                activityItems: viewStore.exportLogsState.zippedLogsURLs
            ) {
                viewStore.send(.exportLogs(.shareFinished))
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .placeholder)
    }
}
