import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: SettingsStore

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(
                    action: { viewStore.send(.backupWalletAccessRequest) },
                    label: { Text("Backup Wallet") }
                )
                .activeButtonStyle
                .frame(height: 50)
                .padding(30)
                
                Button(
                    action: { viewStore.send(.rescanBlockchain) },
                    label: { Text("Rescan Blockchain") }
                )
                .primaryButtonStyle
                .frame(height: 50)
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationTitle("Settings")
            .applyScreenBackground()
            .confirmationDialog(
                store.scope(state: \.rescanDialog),
                dismiss: .cancelRescan
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForBackupPhrase,
                destination: {
                    RecoveryPhraseDisplayView(store: store.backupPhraseStore())
                }
            )
        }
    }
}

// MARK: - Previews

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(store: .placeholder)
    }
}
