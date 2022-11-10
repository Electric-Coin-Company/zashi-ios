import SwiftUI
import StoreKit
import ComposableArchitecture

struct AppView: View {
    let store: AppStore

    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.route {
                case .home:
                    NavigationView {
                        HomeView(
                            store: store.scope(
                                state: \.homeState,
                                action: AppReducer.Action.home
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .sandbox:
                    NavigationView {
                        SandboxView(
                            store: store.scope(
                                state: \.sandboxState,
                                action: AppReducer.Action.sandbox
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .onboarding:
                    NavigationView {
                        OnboardingScreen(
                            store: store.scope(
                                state: \.onboardingState,
                                action: AppReducer.Action.onboarding
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
                                action: AppReducer.Action.phraseValidation
                            )
                        )
                    }
                    .navigationViewStyle(.stack)
                    
                case .phraseDisplay:
                    NavigationView {
                        RecoveryPhraseDisplayView(
                            store: store.scope(
                                state: \.phraseDisplayState,
                                action: AppReducer.Action.phraseDisplay
                            )
                        )
                    }
                    
                case .welcome:
                    WelcomeView(
                        store: store.scope(
                            state: \.welcomeState,
                            action: AppReducer.Action.welcome
                        )
                    )
                }
            }
            .onOpenURL(perform: { viewStore.send(.deeplink($0)) })
        }
    }
}

private extension AppView {
    @ViewBuilder func debugView(_ viewStore: AppViewStore) -> some View {
        List {
            Section(header: Text("Navigation Stack Routes")) {
                Button("Go To Sandbox (navigation proof)") {
                    viewStore.send(.updateRoute(.sandbox))
                }
                
                Button("Go To Onboarding") {
                    viewStore.send(.updateRoute(.onboarding))
                }
                
                Button("Go To Phrase Validation Demo") {
                    viewStore.send(.updateRoute(.phraseValidation))
                }
                
                Button("Restart the app") {
                    viewStore.send(.updateRoute(.welcome))
                }
                
                Button("[Be careful] Nuke Wallet") {
                    viewStore.send(.nukeWallet)
                }
            }
        }
        .navigationBarTitle("Startup")
    }
}

// MARK: - Previews

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppView(
                store: AppStore(
                    initialState: .placeholder,
                    reducer: AppReducer()
                )
            )
        }
    }
}
