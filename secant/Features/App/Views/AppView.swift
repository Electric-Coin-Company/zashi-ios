import SwiftUI
import StoreKit
import ComposableArchitecture

struct AppView: View {
    let store: AppStore

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.route {
            case .home:
                NavigationView {
                    HomeView(
                        store: store.scope(
                            state: \.homeState,
                            action: AppAction.home
                        )
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())

            case .onboarding:
                NavigationView {
                    OnboardingScreen(
                        store: store.scope(
                            state: \.onboardingState,
                            action: AppAction.onboarding
                        )
                    )
                }
                .navigationViewStyle(StackNavigationViewStyle())

            case .startup:
                ZStack(alignment: .topTrailing) {
                    StartupView(sendAction: viewStore.send)
                        .transition(.opacity)
                }

            case .phraseValidation:
                NavigationView {
                    RecoveryPhraseTestPreambleView(
                        store: store.scope(
                            state: \.phraseValidationState,
                            action: AppAction.phraseValidation
                        )
                    )
                    .navigationViewStyle(StackNavigationViewStyle())
                }

            case .phraseDisplay:
                NavigationView {
                    RecoveryPhraseDisplayView(
                        store: store.scope(
                            state: \.phraseDisplayState,
                            action: AppAction.phraseDisplay
                        )
                    )
                }
            case .welcome:
                WelcomeView(
                    store: store.scope(
                        state: \.welcomeState,
                        action: AppAction.welcome
                    )
                )
                .onAppear(perform: { viewStore.send(.checkWalletInitialization) })
            }
        }
    }
}

private struct StartupView: View {
    var sendAction: (AppAction) -> Void

    var body: some View {
        List {
            Section(header: Text("Navigation Stack Routes")) {
                Button("Go To Home") {
                    sendAction(.updateRoute(.home))
                }

                Button("Go To Onboarding") {
                    sendAction(.updateRoute(.onboarding))
                }

                Button("Go To Phrase Validation Demo") {
                    sendAction(.updateRoute(.phraseValidation))
                }

                Button("Go To Welcome Screen") {
                    sendAction(.updateRoute(.welcome))
                }

                Button("[Be careful] Nuke Wallet") {
                    sendAction(.nukeWallet)
                }
            }
        }
        .navigationBarTitle("Startup")
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppView(
                store: AppStore(
                    initialState: .placeholder,
                    reducer: .default,
                    environment: .mock
                )
            )
        }
    }
}
