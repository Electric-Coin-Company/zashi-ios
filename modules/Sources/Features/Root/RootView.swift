import SwiftUI
import StoreKit
import ComposableArchitecture
import Generated
import Models
import NotEnoughFreeSpace
import Welcome
import ExportLogs
import OnboardingFlow
import ZcashLightClientKit
import UIComponents
import DeeplinkWarning
import OSStatusError

//import About
//import AddKeystoneHWWallet
//import AddressBook
//import AddressDetails
import CurrencyConversionSetup
//import DeleteWallet
//import ExportTransactionHistory
import Home
//import PartialProposalError
//import PrivateDataConsent
import Receive
import RecoveryPhraseDisplay
import CoordFlows
//import RequestZec
//import Scan
//import SendConfirmation
//import SendFeedback
//import SendForm
import ServerSetup
import Settings
//import TransactionDetails
//import TransactionsManager
//import WhatsNew
//import ZecKeyboard

public struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var covered = false
    
    @Perception.Bindable var store: StoreOf<Root>
    let tokenName: String
    let networkType: NetworkType

    public init(store: StoreOf<Root>, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }
    
    public var body: some View {
        switchOverDestination()
            .overlay {
                if covered {
                    VStack {
                        ZashiIcon()
                            .scaleEffect(2.0)
                            .padding(.bottom, 180)
                    }
                    .applyScreenBackground()
                }
            }
            .onChange(of: scenePhase) { value in
                covered = value == .background
            }
    }
}

private struct FeatureFlagWrapper: Identifiable, Equatable, Comparable {
    let name: FeatureFlag
    let isEnabled: Bool
    var id: String { name.rawValue }

    static func < (lhs: FeatureFlagWrapper, rhs: FeatureFlagWrapper) -> Bool {
        lhs.name.rawValue < rhs.name.rawValue
    }

    static func == (lhs: FeatureFlagWrapper, rhs: FeatureFlagWrapper) -> Bool {
        lhs.name.rawValue == rhs.name.rawValue
    }
}

private extension RootView {
    @ViewBuilder func switchOverDestination() -> some View {
        WithPerceptionTracking {
            Group {
                switch store.destinationState.destination {
                case .deeplinkWarning:
                    NavigationView {
                        DeeplinkWarningView(
                            store: store.scope(
                                state: \.deeplinkWarningState,
                                action: \.deeplinkWarning
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }
                    
                case .notEnoughFreeSpace:
                    NavigationView {
                        NotEnoughFreeSpaceView(
                            store: store.scope(
                                state: \.notEnoughFreeSpaceState,
                                action: \.notEnoughFreeSpace
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }

                case .osStatusError:
                    NavigationView {
                        OSStatusErrorView(
                            store: store.scope(
                                state: \.osStatusErrorState,
                                action: \.osStatusError
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }

                case .home:
//                    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                    NavigationView {
                        HomeView(
                            store: store.scope(
                                state: \.homeState,
                                action: \.home
                            ),
                            tokenName: tokenName
                        )
                        .navigationLinkEmpty(isActive: store.bindingFor(.settings)) {
                            SettingsView(
                                store:
                                    store.scope(
                                        state: \.settingsState,
                                        action: \.settings)
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.receive)) {
                            ReceiveView(
                                store:
                                    store.scope(
                                        state: \.receiveState,
                                        action: \.receive),
                                networkType: networkType,
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.requestZecCoordFlow)) {
                            RequestZecCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.requestZecCoordFlowState,
                                        action: \.requestZecCoordFlow),
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.sendCoordFlow)) {
                            SendCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.sendCoordFlowState,
                                        action: \.sendCoordFlow),
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.scanCoordFlow)) {
                            ScanCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.scanCoordFlowState,
                                        action: \.scanCoordFlow),
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.addKeystoneHWWalletCoordFlow)) {
                            AddKeystoneHWWalletCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.addKeystoneHWWalletCoordFlowState,
                                        action: \.addKeystoneHWWalletCoordFlow),
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.transactionsCoordFlow)) {
                            TransactionsCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.transactionsCoordFlowState,
                                        action: \.transactionsCoordFlow),
                                tokenName: tokenName
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.currencyConversionSetup)) {
                            CurrencyConversionSetupView(
                                store:
                                    store.scope(
                                        state: \.currencyConversionSetupState,
                                        action: \.currencyConversionSetup)
                            )
                        }
                        .navigationLinkEmpty(isActive: store.bindingFor(.signWithKeystoneCoordFlow)) {
                            SignWithKeystoneCoordFlowView(
                                store:
                                    store.scope(
                                        state: \.signWithKeystoneCoordFlowState,
                                        action: \.signWithKeystoneCoordFlow),
                                tokenName: tokenName
                            )
                        }
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }
                        
//                    } destination: { store in
//                        switch store.case {
//                        case let .about(store):
//                            AboutView(store: store)
//                        case let .accountHWWalletSelection(store):
//                            AccountsSelectionView(store: store)
//                        case let .addKeystoneHWWallet(store):
//                            AddKeystoneHWWalletView(store: store)
//                        case let .addressBook(store):
//                            AddressBookView(store: store)
//                        case let .addressBookContact(store):
//                            AddressBookContactView(store: store)
//                        case let .addressDetails(store):
//                            AddressDetailsView(store: store)
//                        case let .advancedSettings(store):
//                            AdvancedSettingsView(store: store)
//                        case let .chooseServerSetup(store):
//                            ServerSetupView(store: store)
//                        case let .currencyConversionSetup(store):
//                            CurrencyConversionSetupView(store: store)
//                        case let .exportPrivateData(store):
//                            PrivateDataConsentView(store: store)
//                        case let .exportTransactionHistory(store):
//                            ExportTransactionHistoryView(store: store)
//                        case let .integrations(store):
//                            IntegrationsView(store: store)
////                        case let .preSendingFailure(store):
////                            PreSendingFailureView(store: store, tokenName: tokenName)
//                        case let .receive(store):
//                            ReceiveView(store: store, networkType: networkType)
//                        case let .recoveryPhrase(store):
//                            RecoveryPhraseDisplayView(store: store)
//                        case let .requestZec(store):
//                            RequestZecView(store: store, tokenName: tokenName)
////                        case let .requestZecConfirmation(store):
////                            RequestPaymentConfirmationView(store: store, tokenName: tokenName)
//                        case let .requestZecSummary(store):
//                            RequestZecSummaryView(store: store, tokenName: tokenName)
//                        case let .resetZashi(store):
//                            DeleteWalletView(store: store)
//                        case let .scan(store):
//                            ScanView(store: store)
//                        case let .sendConfirmation(store):
//                            SendConfirmationView(store: store, tokenName: tokenName)
//                        case let .sending(store):
//                            SendingView(store: store, tokenName: tokenName)
//                        case let .sendUsFeedback(store):
//                            SendFeedbackView(store: store)
//                        case let .sendForm(store):
//                            SendFormView(store: store, tokenName: tokenName)
//                        case let .sendResultFailure(store):
//                            FailureView(store: store, tokenName: tokenName)
//                        case let .sendResultPartial(store):
//                            PartialProposalErrorView(store: store)
//                        case let .sendResultResubmission(store):
//                            ResubmissionView(store: store, tokenName: tokenName)
//                        case let .sendResultSuccess(store):
//                            SuccessView(store: store, tokenName: tokenName)
//                        case let .settings(store):
//                            SettingsView(store: store)
//                        case let .transactionDetails(store):
//                            TransactionDetailsView(store: store, tokenName: tokenName)
//                        case let .transactionsManager(store):
//                            TransactionsManagerView(store: store, tokenName: tokenName)
//                        case let .whatsNew(store):
//                            WhatsNewView(store: store)
//                        case let .zecKeyboard(store):
//                            ZecKeyboardView(store: store, tokenName: tokenName)
//                        }
//                    }
                //}

                case .phraseDisplay:
                    NavigationView {
                        RecoveryPhraseDisplayView(
                            store: store.scope(
                                state: \.phraseDisplayState,
                                action: \.phraseDisplay
                            )
                        )
                    }
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }

                case .onboarding:
                    NavigationView {
                        PlainOnboardingView(
                            store: store.scope(
                                state: \.onboardingState,
                                action: \.onboarding
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }

                case .startup:
                    ZStack(alignment: .topTrailing) {
                        debugView(store)
                            .transition(.opacity)
                    }
                    
                case .welcome:
                    WelcomeView(
                        store: store.scope(
                            state: \.welcomeState,
                            action: \.welcome
                        )
                    )
                }
            }
            .onOpenURL(perform: { store.goToDeeplink($0) })
            .alert(
                store:
                    store.scope(
                        state: \.$alert,
                        action: \.alert
                    )
            )
            .alert(store: store.scope(
                state: \.exportLogsState.$alert,
                action: \.exportLogs.alert
            ))
            .fullScreenCover(
                isPresented:
                    Binding(
                        get: { store.serverSetupViewBinding },
                        set: { store.send(.serverSetupBindingUpdated($0)) }
                    )
            ) {
                NavigationView {
                    ServerSetupView(
                        store:
                            store.scope(
                                state: \.serverSetupState,
                                action: \.serverSetup
                            )
                    ) {
                        store.send(.serverSetupBindingUpdated(false))
                    }
                }
            }

            shareLogsView(store)
        }
        .toast()
    }
}

private extension RootView {
    @ViewBuilder func shareLogsView(_ store: StoreOf<Root>) -> some View {
        if store.exportLogsState.isSharingLogs {
            UIShareDialogView(
                activityItems: store.exportLogsState.zippedLogsURLs
            ) {
                store.send(.exportLogs(.shareFinished))
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder func debugView(_ store: StoreOf<Root>) -> some View {
        VStack(alignment: .leading) {
            if store.destinationState.previousDestination == .home {
                ZashiButton(L10n.General.back) {
                    store.goToDestination(.home)
                }
                .frame(width: 150)
                .padding()
            }

            List {
                Section(header: Text(L10n.Root.Debug.title)) {
                    Button(L10n.Root.Debug.Option.exportLogs) {
                        store.send(.exportLogs(.start))
                    }
                    .disabled(store.exportLogsState.exportLogsDisabled)

                    Button(L10n.Root.Debug.Option.testCrashReporter) {
                        store.send(.debug(.testCrashReporter))
                    }

#if DEBUG
                    Button(L10n.Root.Debug.Option.appReview) {
                        store.send(.debug(.rateTheApp))
                        if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: currentScene)
                        }
                    }
#endif
                    
                    Button(L10n.Root.Debug.Option.copySeed) {
                        store.send(.debug(.copySeedToPasteboard))
                    }

                    Button(L10n.Root.Debug.Option.rescanBlockchain) {
                        store.send(.debug(.rescanBlockchain))
                    }

                    Button(L10n.Root.Debug.Option.nukeWallet) {
                        store.send(.initialization(.resetZashiRequest))
                    }
                }
            }
            .confirmationDialog(
                store: store.scope(
                    state: \.$confirmationDialog,
                    action: \.confirmationDialog
                )
            )
        }
        .navigationBarTitle(L10n.Root.Debug.navigationTitle)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        RootView(
            store: StoreOf<Root>(
                initialState: .initial
            ) {
                Root()
            },
            tokenName: "ZEC",
            networkType: .testnet
        )
    }
}

// MARK: - Binding

extension StoreOf<Root> {
    func bindingFor(_ path: Root.State.Path) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.path == path },
            set: { self.path = $0 ? path : nil }
        )
    }
}

// MARK: Placeholders

extension Root.State {
    public static var initial: Self {
        .init(
            debugState: .initial,
            destinationState: .initial,
            exportLogsState: .initial,
            onboardingState: .initial,
            phraseDisplayState: .initial,
            //tabsState: .initial,
            walletConfig: .initial,
            welcomeState: .initial
        )
    }
}

extension Root {
    public static var placeholder: StoreOf<Root> {
        StoreOf<Root>(
            initialState: .initial
        ) {
            Root()
                //.logging()
        }
    }
}
