import SwiftUI
import ComposableArchitecture

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
                .disabled(viewStore.exportLogsState.exportLogsDisabled)

                Button(
                    action: { viewStore.send(.sendSupportMail) },
                    label: { Text(L10n.Settings.feedback) }
                )
                .activeButtonStyle
                .frame(height: 50)

                Spacer()
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
            .onAppear { viewStore.send(.onAppear) }
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
            .alert(
                self.store.scope(
                    state: \.exportLogsState.alert,
                    action: { (_: ExportLogsReducer.Action) in return .exportLogs(.dismissAlert) }
                ),
                dismiss: .dismissAlert
            )

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
    }

    @ViewBuilder func shareLogsView(_ viewStore: SettingsViewStore) -> some View {
        if viewStore.exportLogsState.isSharingLogs {
            UIShareDialogView(
                activityItems: [
                    viewStore.exportLogsState.tempSDKDir,
                    viewStore.exportLogsState.tempWalletDir,
                    viewStore.exportLogsState.tempTCADir
                ]
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
