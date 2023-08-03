import SwiftUI
import StoreKit
import ComposableArchitecture
import Generated
import RecoveryPhraseValidationFlow
import Models
import RecoveryPhraseDisplay
import Welcome
import ExportLogs
import OnboardingFlow
import Sandbox
import Home
import ZcashLightClientKit

public struct RootView: View {
    let store: RootStore
    let tokenName: String
    let networkType: NetworkType

    public init(store: RootStore, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }
    
    public var body: some View {
        switchOverDestination()
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
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.destinationState.destination {
                case .home:
                    NavigationView {
                        HomeView(
                            store: store.scope(
                                state: \.homeState,
                                action: RootReducer.Action.home
                            ),
                            tokenName: tokenName
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .sandbox:
                    NavigationView {
                        SandboxView(
                            store: store.scope(
                                state: \.sandboxState,
                                action: RootReducer.Action.sandbox
                            ),
                            tokenName: tokenName,
                            networkType: networkType
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .onboarding:
                    NavigationView {
                        if viewStore.walletConfig
                            .isEnabled(.onboardingFlow) {
                            OnboardingScreen(
                                store: store.scope(
                                    state: \.onboardingState,
                                    action: RootReducer.Action.onboarding
                                )
                            )
                        } else {
                            PlainOnboardingView(
                                store: store.scope(
                                    state: \.onboardingState,
                                    action: RootReducer.Action.onboarding
                                )
                            )
                        }
                    }
                    .navigationViewStyle(.stack)
                    
                case .startup:
                    ZStack(alignment: .topTrailing) {
                        debugView(viewStore)
                            .transition(.opacity)
                    }
                    
                case .phraseValidation:
                    NavigationView {
                        RecoveryPhraseValidationFlowView(
                            store: store.scope(
                                state: \.phraseValidationState,
                                action: RootReducer.Action.phraseValidation
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .phraseDisplay:
                    NavigationView {
                        RecoveryPhraseDisplayView(
                            store: store.scope(
                                state: \.phraseDisplayState,
                                action: RootReducer.Action.phraseDisplay
                            )
                        )
                    }
                    
                case .welcome:
                    WelcomeView(
                        store: store.scope(
                            state: \.welcomeState,
                            action: RootReducer.Action.welcome
                        )
                    )
                }
            }
            .onOpenURL(perform: { viewStore.goToDeeplink($0) })
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .alert(store: store.scope(
                state: \.exportLogsState.$alert,
                action: { .exportLogs(.alert($0)) }
            ))

            shareLogsView(viewStore)
        }
    }
}

private extension RootView {
    @ViewBuilder func shareLogsView(_ viewStore: RootViewStore) -> some View {
        if viewStore.exportLogsState.isSharingLogs {
            UIShareDialogView(
                activityItems: viewStore.exportLogsState.zippedLogsURLs
            ) {
                viewStore.send(.exportLogs(.shareFinished))
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder func debugView(_ viewStore: RootViewStore) -> some View {
        VStack(alignment: .leading) {
            if viewStore.destinationState.previousDestination == .home {
                Button(L10n.General.back) {
                    viewStore.goToDestination(.home)
                }
                .activeButtonStyle
                .frame(width: 150)
                .padding()
            }

            List {
                Section(header: Text(L10n.Root.Debug.title)) {
                    Button(L10n.Root.Debug.Option.exportLogs) {
                        viewStore.send(.exportLogs(.start))
                    }
                    .disabled(viewStore.exportLogsState.exportLogsDisabled)

#if DEBUG
                    Button(L10n.Root.Debug.Option.appReview) {
                        viewStore.send(.debug(.rateTheApp))
                        if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: currentScene)
                        }
                    }
#endif
                    
                    Button(L10n.Root.Debug.Option.rescanBlockchain) {
                        viewStore.send(.debug(.rescanBlockchain))
                    }
                    
                    Button(L10n.Root.Debug.Option.nukeWallet) {
                        viewStore.send(.initialization(.nukeWalletRequest))
                    }
                }
#if DEBUG
                Section(header: Text(L10n.Root.Debug.featureFlags)) {
                    let flags = viewStore.state.walletConfig.flags
                        .map { FeatureFlagWrapper(name: $0.key, isEnabled: $0.value) }
                        .sorted()
                    
                    ForEach(flags) { flag in
                        HStack {
                            Toggle(
                                isOn: Binding(
                                    get: { flag.isEnabled },
                                    set: { _ in
                                        viewStore.send(.debug(.updateFlag(flag.name, flag.isEnabled)))
                                    }
                                ),
                                label: {
                                    Text(flag.name.rawValue)
                                        .foregroundColor(flag.isEnabled ? .green : .red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            )
                        }
                    }
                }
#endif
            }
            .confirmationDialog(
                store.scope(
                    state: \.debugState.rescanDialog,
                    action: { $0 }
                ),
                dismiss: .debug(.cancelRescan)
            )
        }
        .navigationBarTitle(L10n.Root.Debug.navigationTitle)
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootView(
                store: RootStore(
                    initialState: .placeholder,
                    reducer: RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
                ),
                tokenName: "ZEC",
                networkType: .testnet
            )
        }
    }
}
