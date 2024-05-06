import SwiftUI
import ComposableArchitecture
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup

public struct SettingsView: View {
    @State private var isRestoringWalletBadgeOn = false

    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            WithViewStore(store, observe: { $0 }) { viewStore in
                Button(L10n.Settings.feedback.uppercased()) {
                    viewStore.send(.sendSupportMail)
                }
                .zcashStyle()
                .padding(.vertical, 25)
                .padding(.top, 40)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAbout,
                    destination: {
                        About(store: store)
                    }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAdvanced,
                    destination: {
                        AdvancedSettingsView(store: store.advancedSettingsStore())
                    }
                )
                .onAppear {
                    viewStore.send(.onAppear)
                    isRestoringWalletBadgeOn = viewStore.isRestoringWallet
                }
                .onChange(of: viewStore.isRestoringWallet) { isRestoringWalletBadgeOn = $0 }

                Button(L10n.Settings.advanced.uppercased()) {
                    viewStore.send(.updateDestination(.advanced))
                }
                .zcashStyle()
                .padding(.bottom, 25)

                Spacer()
                
                Button(L10n.Settings.about.uppercased()) {
                    viewStore.send(.updateDestination(.about))
                }
                .zcashStyle()
                .padding(.bottom, 40)
                
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
        .zashiBack()
        .zashiTitle {
            Asset.Assets.zashiTitle.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 62, height: 17)
                .foregroundColor(Asset.Colors.primary.color)
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
