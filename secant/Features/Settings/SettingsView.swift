import SwiftUI
import ComposableArchitecture
import Generated
import RecoveryPhraseDisplay

struct SettingsView: View {
    let store: SettingsStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 40) {
                Toggle(
                    L10n.Settings.crashReporting,
                    isOn: viewStore.binding(\.$isCrashReportingOn)
                )
                Button(
                    action: { viewStore.send(.backupWalletAccessRequest) },
                    label: { Text(L10n.Settings.backupWallet) }
                )
                .activeButtonStyle
                .frame(height: 50)
                
                Button(
                    action: { viewStore.send(.exportLogs(.start)) },
                    label: {
                        if viewStore.exportLogsState.exportLogsDisabled {
                            HStack {
                                ProgressView()
                                Text(L10n.Settings.exporting)
                            }
                        } else {
                            Text(L10n.Settings.exportLogs)
                        }
                    }
                )
                .activeButtonStyle
                .frame(height: 50)
                .disable(
                    when: viewStore.exportLogsState.exportLogsDisabled,
                    dimmingOpacity: 0.5
                )
                
                Button(
                    action: { viewStore.send(.sendSupportMail) },
                    label: { Text(L10n.Settings.feedback) }
                )
                .activeButtonStyle
                .frame(height: 50)

                Spacer()
                
                Button(
                    action: { viewStore.send(.updateDestination(.about)) },
                    label: { Text(L10n.Settings.about) }
                )
                .activeButtonStyle
                .frame(maxHeight: 50)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 30)
            .navigationTitle(L10n.Settings.title)
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
