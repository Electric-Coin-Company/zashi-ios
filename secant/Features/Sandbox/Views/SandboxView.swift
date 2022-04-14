import SwiftUI
import ComposableArchitecture

struct SandboxView: View {
    let store: Store<SandboxState, SandboxAction>

    var navigationRouteValues: [SandboxRouteValue] = SandboxState.Route.allCases
        .enumerated()
        .filter { $0.1 != .history }
        .map { SandboxRouteValue(id: $0.0, route: $0.1) }

    var modalRoutes: [SandboxRouteValue] = SandboxState.Route.allCases
        .enumerated()
        .filter { $0.1 == .history }
        .map { SandboxRouteValue(id: $0.0, route: $0.1) }

    @ViewBuilder func view(for route: SandboxState.Route) -> some View {
        switch route {
        case .history:
            TransactionHistoryView(store: store.historyStore())
        case .send:
            SendView(
                store: .init(
                    initialState: .placeholder,
                    reducer: SendReducer.default(
                        whenDone: { SandboxViewStore(store).send(.updateRoute(nil)) }
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
            .navigationBarTitle("Sandbox")
        }
    }
}

struct SandboxRouteValue: Identifiable {
    let id: Int
    let route: SandboxState.Route
}

// MARK: - Previews

extension SandboxStore {
    static var placeholder: SandboxStore {
        SandboxStore(
            initialState: SandboxState(
                transactionHistoryState: .placeHolder,
                profileState: .placeholder,
                route: nil
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}

struct SandboxView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SandboxView(store: .placeholder)
        }
    }
}
