import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: SettingsStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 40) {
                Toggle(
                    "settings.crashReporting",
                    isOn: viewStore.binding(\.$isCrashReportingOn)
                )
                Button(
                    action: { viewStore.send(.backupWalletAccessRequest) },
                    label: { Text("settings.backupWallet") }
                )
                .activeButtonStyle
                .frame(height: 50)
                
                Button(
                    action: { viewStore.send(.exportLogs) },
                    label: {
                        if viewStore.exportLogsDisabled {
                            HStack {
                                ProgressView()
                                Text("settings.exporting")
                            }
                        } else {
                            Text("settings.exportLogs")
                        }
                    }
                )
                .activeButtonStyle
                .frame(height: 50)
                .disabled(viewStore.exportLogsDisabled)

                Button(
                    action: { viewStore.send(.sendSupportMail) },
                    label: { Text("settings.feedback") }
                )
                .activeButtonStyle
                .frame(height: 50)

                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationTitle("settings.title")
            .applyScreenBackground()
            .navigationLinkEmpty(
                isActive: viewStore.bindingForBackupPhrase,
                destination: {
                    RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                }
            )
            .onAppear { viewStore.send(.onAppear) }
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
            
            if viewStore.isSharingLogs {
                UIShareDialogView(
                    activityItems: [viewStore.tempSDKDir, viewStore.tempWalletDir, viewStore.tempTCADir]
                ) {
                    viewStore.send(.logsShareFinished)
                }
                // UIShareDialogView only wraps UIActivityViewController presentation
                // so frame is set to 0 to not break SwiftUIs layout
                .frame(width: 0, height: 0)
            }

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
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .placeholder)
    }
}
