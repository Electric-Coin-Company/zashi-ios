import SwiftUI
import ComposableArchitecture
import RecoveryPhraseDisplay
import Profile
import WalletEventsFlow
import Scan

struct SandboxView: View {
    struct SandboxDestinationValue: Identifiable {
        let id: Int
        let destination: SandboxReducer.State.Destination
    }
    
    let store: SandboxStore

    var navigationDestinationValues: [SandboxDestinationValue] = SandboxReducer.State.Destination.allCases
        .enumerated()
        .filter { $0.1 != .history }
        .map { SandboxDestinationValue(id: $0.0, destination: $0.1) }

    var modalDestinations: [SandboxDestinationValue] = SandboxReducer.State.Destination.allCases
        .enumerated()
        .filter { $0.1 == .history }
        .map { SandboxDestinationValue(id: $0.0, destination: $0.1) }

    @ViewBuilder func view(for destination: SandboxReducer.State.Destination) -> some View {
        switch destination {
        case .history:
            WalletEventsFlowView(store: store.historyStore(), tokenName: TargetConstants.tokenName)
        case .send:
            SendFlowView(
                store: .init(
                    initialState: .placeholder,
                    reducer: SendFlowReducer()
                )
            )
        case .recoveryPhraseDisplay:
            RecoveryPhraseDisplayView(store: .demo)
        case .scan:
            ScanView(store: .placeholder)
        case .profile:
            ProfileView(store: store.profileStore())
        }
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    Section(header: Text("Navigation Stack Destinations")) {
                        ForEach(navigationDestinationValues) { destinationValue in
                            Text("\(String(describing: destinationValue.destination))")
                                .navigationLink(
                                    isActive: viewStore.bindingForDestination(destinationValue.destination),
                                    destination: {
                                        view(for: destinationValue.destination)
                                    }
                                )
                        }
                    }

                    Section(header: Text("Modal Destinations")) {
                        ForEach(modalDestinations) { destinationValue in
                            Button(
                                action: { viewStore.send(.updateDestination(destinationValue.destination)) },
                                label: { Text("\(String(describing: destinationValue.destination))") }
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
                isPresented: viewStore.bindingForDestination(.history),
                content: {
                    NavigationView {
                        WalletEventsFlowView(store: store.historyStore(), tokenName: TargetConstants.tokenName)
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") { viewStore.send(.updateDestination(nil)) }
                                }
                            }
                    }
                }
            )
            .navigationBarTitle("Sandbox")
        }
    }
}

// MARK: - Previews

struct SandboxView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SandboxView(store: .placeholder)
        }
    }
}
