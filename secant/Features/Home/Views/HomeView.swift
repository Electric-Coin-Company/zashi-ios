import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button(
                    action: { viewStore.toggleShowingHistory() },
                    label: { Text(viewStore.historyToggleString()) }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Button(
                    action: { viewStore.toggleSelectedTransaction() },
                    label: { Text("Toggle Selected Transaction") }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Button(
                    action: { viewStore.send(.updateRoute(.send)) },
                    label: { Text("Go to Send") }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Button(
                    action: { viewStore.send(.updateRoute(.onboarding)) },
                    label: { Text("Show Onboarding") }
                )
                .primaryButtonStyle
                .frame(height: 50)

                Spacer()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Route: \(String(dumping: viewStore.route))")
                        Text(
                            // swiftlint:disable:next line_length
                            "SelectedTransaction: \(String(dumping: viewStore.transactionHistoryState.route.map(/TransactionHistoryState.Route.showTransaction)))"
                        )
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationLinkEmpty(
                isActive: viewStore.showSendBinding,
                destination: {
                    SendView(
                        store: .init(
                            initialState: .init(
                                transaction: .demo,
                                route: nil
                            ),
                            reducer: SendReducer.default(
                                whenDone: { viewStore.send(.updateRoute(nil)) }
                            )
                            .debug(),
                            environment: ()
                        )
                    )
                }
            )
            .navigationLinkEmpty(
                isActive: viewStore.showOnboardingBinding,
                destination: {
                    OnboardingScreen(
                        store: Store(
                            initialState: OnboardingState(),
                            reducer: .default,
                            environment: ()
                        )
                    )
                }
            )
            .fullScreenCover(
                isPresented: viewStore.showHistoryBinding,
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
        }
    }
}

extension HomeStore {
    static var demo: HomeStore {
        HomeStore(
            initialState: HomeState(
                transactionHistoryState: .init(
                    transactions: .demo,
                    route: nil
                ),
                route: nil
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .demo)
        }
    }
}
