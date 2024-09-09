import SwiftUI
import ComposableArchitecture

import About
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup

public struct SettingsView: View {
    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                List {
                    Group {
                        SettingsRow(
                            icon: Asset.Assets.Icons.settings.image,
                            title: L10n.Settings.advanced
                        ) {
                            viewStore.send(.updateDestination(.advanced))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.infoOutline.image,
                            title: L10n.Settings.about
                        ) {
                            viewStore.send(.updateDestination(.about))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.Icons.messageSmile.image,
                            title: L10n.Settings.feedback,
                            divider: false
                        ) {
                            viewStore.send(.sendSupportMail)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForAbout,
                    destination: {
                        AboutView(store: store.aboutStore())
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
                
                Spacer()
                
                Asset.Assets.zashiTitle.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 73, height: 20)
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.bottom, 16)
                
                Text(L10n.Settings.version(viewStore.appVersion, viewStore.appBuild))
                    .font(.custom(FontFamily.Archivo.regular.name, size: 16))
                    .foregroundColor(Asset.Colors.V2.textPrimary.color)
                    .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .alert(store: store.scope(
            state: \.$alert,
            action: { .alert($0) }
        ))
        .zashiBack()
        .zashiTitle {
            Text(L10n.Settings.title.uppercased())
                .font(.custom(FontFamily.Archivo.bold.name, size: 14))
        }
        .walletStatusPanel()
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        SettingsView(store: .placeholder)
    }
}
