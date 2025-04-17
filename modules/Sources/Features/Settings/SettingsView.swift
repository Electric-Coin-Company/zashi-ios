import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents

import About
import AddKeystoneHWWallet
import AddressBook
import ServerSetup
import CurrencyConversionSetup
import PrivateDataConsent
import ExportTransactionHistory
import DeleteWallet
import Scan
import SendFeedback
import WhatsNew

public struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<Settings>
    
    public init(store: StoreOf<Settings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            //NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    List {
                        Group {
                            ActionRow(
                                icon: Asset.Assets.Icons.user.image,
                                title: L10n.Settings.addressBook
                            ) {
                                store.send(.addressBookAccessCheck)
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
                                                    .seekOutline(colorScheme)
                                                
                                                if store.featureFlags.flexa {
                                                    Asset.Assets.Partners.flexaSeeklogoDisabled.image
                                                        .seekOutline(colorScheme)
                                                }
                                            } else {
                                                Asset.Assets.Partners.coinbaseSeeklogo.image
                                                    .seekOutline(colorScheme)
                                                
                                                if store.featureFlags.flexa {
                                                    Asset.Assets.Partners.flexaSeekLogo.image
                                                        .seekOutline(colorScheme)
                                                }
                                                
                                                if !store.isKeystoneConnected {
                                                    Asset.Assets.Partners.keystoneSeekLogo.image
                                                        .seekOutline(colorScheme)
                                                }
                                            }
                                        }
                                ) {
                                    store.send(.integrationsTapped)
                                }
                                .disabled(store.isKeystoneAccount)
                            }
                            
                            ActionRow(
                                icon: Asset.Assets.Icons.settings.image,
                                title: L10n.Settings.advanced
                            ) {
                                store.send(.advancedSettingsTapped)
                            }
                            
                            ActionRow(
                                icon: Asset.Assets.Icons.magicWand.image,
                                title: L10n.Settings.whatsNew
                            ) {
                                store.send(.whatsNewTapped)
                            }
                            
                            ActionRow(
                                icon: Asset.Assets.infoOutline.image,
                                title: L10n.Settings.about
                            ) {
                                store.send(.aboutTapped)
                            }
                            
                            ActionRow(
                                icon: Asset.Assets.Icons.messageSmile.image,
                                title: L10n.Settings.feedback,
                                divider: false
                            ) {
                                store.send(.sendUsFeedbackTapped)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Asset.Colors.background.color)
                        .listRowSeparator(.hidden)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 4)
                    .onAppear { store.send(.onAppear) }

                    Spacer()
                    
                    Asset.Assets.zashiTitle.image
                        .zImage(width: 73, height: 20, color: Asset.Colors.primary.color)
                        .padding(.bottom, 16)
                    
                    Text(L10n.Settings.version(store.appVersion, store.appBuild))
                        .zFont(size: 16, style: Design.Text.tertiary)
                        .padding(.bottom, 24)
                }
                .listStyle(.plain)
                //.applyScreenBackground()
//            } destination: { store in
//                switch store.case {
//                case let .about(store):
//                    AboutView(store: store)
//                case let .accountHWWalletSelection(store):
//                    AccountsSelectionView(store: store)
//                case let .addKeystoneHWWallet(store):
//                    AddKeystoneHWWalletView(store: store)
//                case let .addressBook(store):
//                    AddressBookView(store: store)
//                case let .addressBookContact(store):
//                    AddressBookContactView(store: store)
//                case let .advancedSettings(store):
//                    AdvancedSettingsView(store: store)
//                case let .chooseServerSetup(store):
//                    ServerSetupView(store: store)
//                case let .currencyConversionSetup(store):
//                    CurrencyConversionSetupView(store: store)
//                case let .exportPrivateData(store):
//                    PrivateDataConsentView(store: store)
//                case let .exportTransactionHistory(store):
//                    ExportTransactionHistoryView(store: store)
//                case let .integrations(store):
//                    IntegrationsView(store: store)
//                case let .resetZashi(store):
//                    DeleteWalletView(store: store)
//                case let .scan(store):
//                    ScanView(store: store)
//                case let .sendUsFeedback(store):
//                    SendFeedbackView(store: store)
//                case let .whatsNew(store):
//                    WhatsNewView(store: store)
//                }
//            }
            .applyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .zashiBack()
            .screenTitle(L10n.Settings.title)
            .walletStatusPanel()
        }
    }
}

extension Image {
    func seekOutline(_ colorScheme: ColorScheme) -> some View {
        self
            .resizable()
            .frame(width: 20, height: 20)
            .background { Circle().fill(Design.Surfaces.bgPrimary.color(colorScheme)).frame(width: 26, height: 26) }
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
    public static let initial = Settings.State()
}

extension StoreOf<Settings> {
    public static let placeholder = StoreOf<Settings>(
        initialState: .initial
    ) {
        Settings()
    }
}
