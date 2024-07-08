import SwiftUI
import ComposableArchitecture

import About
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup

public struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<Settings>
    
    public init(store: StoreOf<Settings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    Group {
                        SettingsRow(
                            icon: Asset.Assets.Icons.integrations.image,
                            title: L10n.Settings.integrations
                        ) {
                            store.send(.updateDestination(.integrations))
                        }

                        SettingsRow(
                            icon: Asset.Assets.Icons.settings.image,
                            title: L10n.Settings.advanced
                        ) {
                            store.send(.updateDestination(.advanced))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.infoOutline.image,
                            title: L10n.Settings.about
                        ) {
                            store.send(.updateDestination(.about))
                        }
                        
                        SettingsRow(
                            icon: Asset.Assets.Icons.messageSmile.image,
                            title: L10n.Settings.feedback,
                            divider: false
                        ) {
                            store.send(.sendSupportMail)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.shade97.color)
                    .listRowSeparator(.hidden)
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.about),
                    destination: {
                        AboutView(store: store.aboutStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.advanced),
                    destination: {
                        AdvancedSettingsView(store: store.advancedSettingsStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.integrations),
                    destination: {
                        IntegrationsView(store: store.integrationsStore())
                    }
                )
                .onAppear {
                    store.send(.onAppear)
                }
                
                if let supportData = store.supportData {
                    UIMailDialogView(
                        supportData: supportData,
                        completion: {
                            store.send(.sendSupportMailFinished)
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
                
                Text(L10n.Settings.version(store.appVersion, store.appBuild))
                    .font(.custom(FontFamily.Archivo.regular.name, size: 16))
                    .foregroundColor(Design.Text.tertiary.color)
                    .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .alert(store: store.scope(
            state: \.$alert,
            action: \.alert
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

// MARK: Placeholders

extension Settings.State {
    public static let initial = Settings.State(
        aboutState: .initial,
        advancedSettingsState: .initial,
        integrationsState: .initial
    )
}

extension StoreOf<Settings> {
    public static let placeholder = StoreOf<Settings>(
        initialState: .initial
    ) {
        Settings()
    }
    
    public static let demo = StoreOf<Settings>(
        initialState: .init(
            aboutState: .initial,
            advancedSettingsState: .initial,
            appVersion: "0.0.1",
            appBuild: "54",
            integrationsState: .initial
        )
    ) {
        Settings()
    }
}

// MARK: - Store

extension StoreOf<Settings> {
    func advancedSettingsStore() -> StoreOf<AdvancedSettings> {
        self.scope(
            state: \.advancedSettingsState,
            action: \.advancedSettings
        )
    }
    
    func aboutStore() -> StoreOf<About> {
        self.scope(
            state: \.aboutState,
            action: \.about
        )
    }
    
    func integrationsStore() -> StoreOf<Integrations> {
        self.scope(
            state: \.integrationsState,
            action: \.integrations
        )
    }
}

// MARK: - Bindings

extension StoreOf<Settings> {
    func bindingFor(_ destination: Settings.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}
