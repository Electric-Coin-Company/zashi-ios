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
                OnboardingScreen(
                    store: store.scope(
                        state: \.onboardingState,
                        action: AppAction.onboarding
                    )
                )
            case .startup:
                ZStack(alignment: .topTrailing) {
                    StartupView(sendAction: viewStore.send)
                }
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
                    environment: .init()
                )
            )
        }
    }
}
