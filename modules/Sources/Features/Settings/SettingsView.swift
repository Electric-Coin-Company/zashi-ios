import SwiftUI
import ComposableArchitecture

import About
import Generated
import RecoveryPhraseDisplay
import UIComponents
import PrivateDataConsent
import ServerSetup
import AddressBook
import WhatsNew
import SendFeedback

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
                        ActionRow(
                            icon: Asset.Assets.Icons.user.image,
                            title: L10n.Settings.addressBook
                        ) {
                            store.send(.protectedAccessRequest(.addressBook))
                        }

                        if store.isEnoughFreeSpaceMode {
                            ActionRow(
                                icon: Asset.Assets.Icons.integrations.image,
                                title: L10n.Settings.integrations,
                                desc: store.isKeystoneAccount
                                ? L10n.Keystone.settings
                                : nil,
                                accessoryView:
                                    HStack(spacing: 0) {
                                        if store.isKeystoneAccount {
                                            Asset.Assets.Partners.coinbaseSeeklogoDisabled.image
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            
                                            if store.featureFlags.flexa {
                                                Asset.Assets.Partners.flexaSeeklogoDisabled.image
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .offset(x: -4)
                                            }
                                        } else {
                                            Asset.Assets.Partners.coinbaseSeeklogo.image
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                            
                                            if store.featureFlags.flexa {
                                                Asset.Assets.Partners.flexaSeekLogo.image
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .offset(x: -4)
                                            }
                                        }
                                    }
                            ) {
                                store.send(.updateDestination(.integrations))
                            }
                            .disabled(store.isKeystoneAccount)
                        }

                        ActionRow(
                            icon: Asset.Assets.Icons.settings.image,
                            title: L10n.Settings.advanced
                        ) {
                            store.send(.updateDestination(.advanced))
                        }

                        ActionRow(
                            icon: Asset.Assets.Icons.magicWand.image,
                            title: L10n.Settings.whatsNew
                        ) {
                            store.send(.updateDestination(.whatsNew))
                        }

                        ActionRow(
                            icon: Asset.Assets.infoOutline.image,
                            title: L10n.Settings.about
                        ) {
                            store.send(.updateDestination(.about))
                        }
                        
                        ActionRow(
                            icon: Asset.Assets.Icons.messageSmile.image,
                            title: L10n.Settings.feedback,
                            divider: false
                        ) {
                            store.send(.updateDestination(.sendFeedback))
                            //store.send(.sendSupportMail)
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
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.addressBook),
                    destination: {
                        AddressBookView(store: store.addressBookStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.whatsNew),
                    destination: {
                        WhatsNewView(store: store.whatsNewStore())
                    }
                )
                .navigationLinkEmpty(
                    isActive: store.bindingFor(.sendFeedback),
                    destination: {
                        SendFeedbackView(store: store.sendFeedbackStore())
                    }
                )
                .onAppear {
                    store.send(.onAppear)
                }

                Spacer()
                
                Asset.Assets.zashiTitle.image
                    .zImage(width: 73, height: 20, color: Asset.Colors.primary.color)
                    .padding(.bottom, 16)
                
                Text(L10n.Settings.version(store.appVersion, store.appBuild))
                    .zFont(size: 16, style: Design.Text.tertiary)
                    .padding(.bottom, 24)
            }
        }
        .applyScreenBackground()
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .zashiBack()
        .screenTitle(L10n.Settings.title)
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
        addressBookState: .initial,
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
            addressBookState: .initial,
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

    func addressBookStore() -> StoreOf<AddressBook> {
        self.scope(
            state: \.addressBookState,
            action: \.addressBook
        )
    }

    func integrationsStore() -> StoreOf<Integrations> {
        self.scope(
            state: \.integrationsState,
            action: \.integrations
        )
    }

    func sendFeedbackStore() -> StoreOf<SendFeedback> {
        self.scope(
            state: \.sendFeedbackState,
            action: \.sendFeedback
        )
    }

    func whatsNewStore() -> StoreOf<WhatsNew> {
        self.scope(
            state: \.whatsNewState,
            action: \.whatsNew
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
