import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents

import About
import AddKeystoneHWWallet
import AddressBook
import CurrencyConversionSetup
import DeleteWallet
import ExportTransactionHistory
import PrivateDataConsent
import RecoveryPhraseDisplay
import Scan
import ServerSetup
import SendFeedback
import WhatsNew
import TorSetup

public struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<Settings>
    
    public init(store: StoreOf<Settings>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                VStack {
                    List {
                        Group {
                            ActionRow(
                                icon: Asset.Assets.Icons.user.image,
                                title: L10n.Settings.addressBook
                            ) {
                                store.send(.addressBookAccessCheck)
                            }

                            ActionRow(
                                icon: Asset.Assets.Icons.trPaid.image,
                                title: L10n.Settings.flexa
                            ) {
                                store.send(.payWithFlexaTapped)
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
                        .onLongPressGesture {
                            store.send(.enableDebugMode)
                        }

                    Text(L10n.Settings.version(store.appVersion, store.appBuild))
                        .zFont(size: 16, style: Design.Text.tertiary)
                        .padding(.bottom, 24)
                }
                .listStyle(.plain)
                .applyScreenBackground()
            } destination: { store in
                switch store.case {
                case let .about(store):
                    AboutView(store: store)
                case let .accountHWWalletSelection(store):
                    AccountsSelectionView(store: store)
                case let .addKeystoneHWWallet(store):
                    AddKeystoneHWWalletView(store: store)
                case let .addressBook(store):
                    AddressBookView(store: store)
                case let .addressBookContact(store):
                    AddressBookContactView(store: store)
                case let .advancedSettings(store):
                    AdvancedSettingsView(store: store)
                case let .chooseServerSetup(store):
                    ServerSetupView(store: store)
                case let .currencyConversionSetup(store):
                    CurrencyConversionSetupView(store: store)
                case let .exportPrivateData(store):
                    PrivateDataConsentView(store: store)
                case let .exportTransactionHistory(store):
                    ExportTransactionHistoryView(store: store)
                case let .recoveryPhrase(store):
                    RecoveryPhraseDisplayView(store: store)
                case let .resetZashi(store):
                    DeleteWalletView(store: store)
                case let .scan(store):
                    ScanView(store: store)
                case let .sendUsFeedback(store):
                    SendFeedbackView(store: store)
                case let .torSetup(store):
                    TorSetupView(store: store)
                case let .whatsNew(store):
                    WhatsNewView(store: store)
                }
            }
            .applyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .zashiBack()
            .navigationBarHidden(!store.path.isEmpty)
            .screenTitle(L10n.HomeScreen.more)
            .zashiSheet(isPresented: $store.isInDebugMode) {
                helpSheetContent()
                    .screenHorizontalPadding()
                    .applyScreenBackground()
            }
        }
    }
    
    @ViewBuilder private func helpSheetContent() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.RecoverFunds.title)
                .zFont(.semiBold, size: 24, style: Design.Text.primary)
                .padding(.top, 24)
                .padding(.bottom, 12)

            Text(L10n.RecoverFunds.msg)
                .zFont(size: 14, style: Design.Text.tertiary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 24)
            
            ZashiTextField(
                addressFont: true,
                text: $store.addressToRecoverFunds,
                placeholder: L10n.RecoverFunds.placeholder,
                title: L10n.RecoverFunds.fieldTitle
            )
            .padding(.bottom, 32)

            if !store.isTorOn {
                HStack(alignment: .top, spacing: 0) {
                    Asset.Assets.infoOutline.image
                        .zImage(size: 20, style: Design.Utility.WarningYellow._500)
                        .padding(.trailing, 12)
                    
                    Text(L10n.RecoverFunds.tor)
                        .zFont(size: 12, style: Design.Utility.WarningYellow._700)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 12)
            }
            
            ZashiButton(L10n.RecoverFunds.btn) {
                store.send(.checkFundsForAddress(store.addressToRecoverFunds))
            }
            .disabled(store.addressToRecoverFunds.isEmpty || !store.isTorOn)
            .padding(.bottom, 24)
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
