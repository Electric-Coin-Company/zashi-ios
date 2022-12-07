import SwiftUI
import StoreKit
import ComposableArchitecture

struct RootView: View {
    let store: RootStore

    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.destinationState.destination {
                case .home:
                    NavigationView {
                        HomeView(
                            store: store.scope(
                                state: \.homeState,
                                action: RootReducer.Action.home
                            )
                        )
                    }
                    .navigationViewStyle(.stack)

                case .sandbox:
                    NavigationView {
                        SandboxView(
                            store: store.scope(
                                state: \.sandboxState,
                                action: RootReducer.Action.sandbox
                            )
                        )
                    }
                    .navigationViewStyle(.stack)

                case .onboarding:
                    NavigationView {
                        OnboardingScreen(
                            store: store.scope(
                                state: \.onboardingState,
                                action: RootReducer.Action.onboarding
                            )
                        )
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
        }
    }
}

private extension RootView {
    @ViewBuilder func debugView(_ viewStore: RootViewStore) -> some View {
        List {
            Section(header: Text("Navigation Stack Destinations")) {
                Button("Go To Sandbox (navigation proof)") {
                    viewStore.goToDestination(.sandbox)
                }
                
                Button("Go To Onboarding") {
                    viewStore.goToDestination(.onboarding)
                }
                
                Button("Go To Phrase Validation Demo") {
                    viewStore.goToDestination(.phraseValidation)
                }
                
                Button("Restart the app") {
                    viewStore.goToDestination(.welcome)
                }
                
                Button("[Be careful] Nuke Wallet") {
                    viewStore.send(.initialization(.nukeWallet))
                }
            }
        }
        .navigationBarTitle("Startup")
    }
}

// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootView(
                store: RootStore(
                    initialState: .placeholder,
                    reducer: RootReducer()
                )
            )
        }
    }
}
