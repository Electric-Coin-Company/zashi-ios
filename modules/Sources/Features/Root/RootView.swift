import SwiftUI
import StoreKit
import ComposableArchitecture
import Generated
import Models
import NotEnoughFreeSpace
import RecoveryPhraseDisplay
import Welcome
import ExportLogs
import OnboardingFlow
import Sandbox
import Tabs
import ZcashLightClientKit
import UIComponents
import ServerSetup
import AddressBook

public struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var covered = false
    
    let store: StoreOf<Root>
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

                case .tabs:
                    NavigationView {
                        TabsView(
                            store: store.scope(
                                state: \.tabsState,
                                action: \.tabs
                            ),
                            tokenName: tokenName,
                            networkType: networkType
                        )
                        .navigationLinkEmpty(
                            isActive: Binding<Bool>(
                                get: {
                                    store.addressBookBinding
                                }, set: {
                                    store.send(.addressBookBinding($0))
                                }
                            ),
                            destination: {
                                AddressBookView(
                                    store: store.scope(
                                        state: \.addressBookState,
                                        action: \.addressBook
                                    )
                                )
                            }
                        )
                        .navigationLinkEmpty(
                            isActive: Binding<Bool>(
                                get: {
                                    store.addressBookContactBinding
                                }, set: {
                                    store.send(.addressBookContactBinding($0))
                                }
                            ),
                            destination: {
                                AddressBookContactView(
                                    store: store.scope(
                                        state: \.addressBookState,
                                        action: \.addressBook
                                    )
                                )
                            }
                        )
                    }
                    .navigationViewStyle(.stack)
                    .overlayedWithSplash(store.splashAppeared) {
                        store.send(.splashRemovalRequested)
                    }

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

                case .sandbox:
                    NavigationView {
                        SandboxView(
                            store: store.scope(
                                state: \.sandboxState,
                                action: \.sandbox
                            ),
                            tokenName: tokenName,
                            networkType: networkType
                        )
                    }
                    .navigationViewStyle(.stack)
                    
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
            if store.destinationState.previousDestination == .tabs {
                Button(L10n.General.back.uppercased()) {
                    store.goToDestination(.tabs)
                }
                .zcashStyle()
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
                        store.send(.initialization(.nukeWalletRequest))
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

// MARK: Placeholders

extension Root.State {
    public static var initial: Self {
        .init(
            debugState: .initial,
            destinationState: .initial,
            exportLogsState: .initial,
            onboardingState: .initial,
            phraseDisplayState: .initial,
            sandboxState: .initial,
            tabsState: .initial,
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
                .logging()
        }
    }
}
