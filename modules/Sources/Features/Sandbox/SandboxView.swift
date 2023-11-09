import SwiftUI
import ComposableArchitecture
import RecoveryPhraseDisplay
import TransactionList
import Scan
import SendFlow
import ZcashLightClientKit

public struct SandboxView: View {
    struct SandboxDestinationValue: Identifiable {
        let id: Int
        let destination: SandboxReducer.State.Destination
    }
    
    let store: SandboxStore
    let tokenName: String
    let networkType: NetworkType

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
            TransactionListView(store: store.historyStore(), tokenName: tokenName)
        case .send:
            SendFlowView(
                store: .init(
                    initialState: .placeholder,
                    reducer: SendFlowReducer(networkType: networkType)
                ),
                tokenName: tokenName
            )
        case .recoveryPhraseDisplay:
            RecoveryPhraseDisplayView(store: .placeholder)
        case .scan:
            ScanView(store: .placeholder)
        }
    }

    public init(store: SandboxStore, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }
    
    public var body: some View {
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
                        TransactionListView(store: store.historyStore(), tokenName: tokenName)
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
            SandboxView(store: .placeholder, tokenName: "ZEC", networkType: .testnet)
        }
    }
}
