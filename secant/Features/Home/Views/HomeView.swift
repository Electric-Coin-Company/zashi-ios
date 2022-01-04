import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var navigationRouteValues: [RouteValue] = HomeState.Route.allCases
        .enumerated()
        .filter { $0.1 != .history }
        .map { RouteValue(id: $0.0, route: $0.1) }

    var modalRoutes: [RouteValue] = HomeState.Route.allCases
        .enumerated()
        .filter { $0.1 == .history }
        .map { RouteValue(id: $0.0, route: $0.1) }

    @ViewBuilder func view(for route: HomeState.Route) -> some View {
        switch route {
        case .history:
            TransactionHistoryView(store: store.historyStore())
        case .send:
            SendView(
                store: .init(
                    initialState: .placeholder,
                    reducer: SendReducer.default(
                        whenDone: { HomeViewStore(store).send(.updateRoute(nil)) }
                    )
                        .debug(),
                    environment: ()
                )
            )
        case .recoveryPhraseDisplay:
            RecoveryPhraseDisplayView(store: .demo)
        case .scan:
            ScanView()
        case .profile:
            ProfileView(store: store.profileStore())
        case .request:
            RequestView()
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    Section(header: Text("Navigation Stack Routes")) {
                        ForEach(navigationRouteValues) { routeValue in
                            Text("\(String(describing: routeValue.route))")
                                .navigationLink(
                                    isActive: viewStore.bindingForRoute(routeValue.route),
                                    destination: {
                                        view(for: routeValue.route)
                                    }
                                )
                        }
                    }

                    Section(header: Text("Modal Routes")) {
                        ForEach(modalRoutes) { routeValue in
                            Button(
                                action: { viewStore.send(.updateRoute(routeValue.route)) },
                                label: { Text("\(String(describing: routeValue.route))") }
                            )
                        }
                    }

                    Section(header: Text("Other Actions")) {
                        Button(
                            action: { viewStore.toggleSelectedTransaction() },
                            label: { Text("Toggle Selected Transaction") }
                        )

                        Button(
                            action: { viewStore.send(.reset) },
                            label: { Text("Reset (to startup)") }
                        )
                    }
                }
            }
            .fullScreenCover(
                isPresented: viewStore.bindingForRoute(.history),
                content: {
                    NavigationView {
                        TransactionHistoryView(store: store.historyStore())
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") { viewStore.send(.updateRoute(nil)) }
                                }
                            }
                    }
                }
            )
            .navigationBarTitle("Home")
        }
    }
}

struct RouteValue: Identifiable {
    let id: Int
    let route: HomeState.Route
}

// MARK: - Previews

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: HomeState(
                transactionHistoryState: .placeHolder,
                profileState: .placeholder,
                route: nil
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder)
        }
    }
}
