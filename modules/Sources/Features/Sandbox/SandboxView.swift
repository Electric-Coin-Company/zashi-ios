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
        let destination: Sandbox.State.Destination
    }
    
    @Perception.Bindable var store: StoreOf<Sandbox>
    let tokenName: String
    let networkType: NetworkType

    var navigationDestinationValues: [SandboxDestinationValue] = Sandbox.State.Destination.allCases
        .enumerated()
        .filter { $0.1 != .history }
        .map { SandboxDestinationValue(id: $0.0, destination: $0.1) }

    var modalDestinations: [SandboxDestinationValue] = Sandbox.State.Destination.allCases
        .enumerated()
        .filter { $0.1 == .history }
        .map { SandboxDestinationValue(id: $0.0, destination: $0.1) }

    @ViewBuilder func view(for destination: Sandbox.State.Destination) -> some View {
        switch destination {
        case .history:
            TransactionListView(store: store.historyStore(), tokenName: tokenName)
        case .send:
            SendFlowView(
                store: .init(
                    initialState: .initial
                ) {
                    SendFlow()
                },
                tokenName: tokenName
            )
        case .recoveryPhraseDisplay:
            RecoveryPhraseDisplayView(store: RecoveryPhraseDisplay.placeholder)
        case .scan:
            ScanView(store: Scan.placeholder)
        }
    }

    public init(store: StoreOf<Sandbox>, tokenName: String, networkType: NetworkType) {
        self.store = store
        self.tokenName = tokenName
        self.networkType = networkType
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    Section(header: Text("Navigation Stack Destinations")) {
                        ForEach(navigationDestinationValues) { destinationValue in
                            Text("\(String(describing: destinationValue.destination))")
                                .navigationLink(
                                    isActive: store.bindingFor(destinationValue.destination),
                                    destination: {
                                        view(for: destinationValue.destination)
                                    }
                                )
                        }
                    }

                    Section(header: Text("Modal Destinations")) {
                        ForEach(modalDestinations) { destinationValue in
                            Button(
                                action: { store.send(.updateDestination(destinationValue.destination)) },
                                label: { Text("\(String(describing: destinationValue.destination))") }
                            )
                        }
                    }

                    Section(header: Text("Other Actions")) {
                        Button(
                            action: { store.send(.reset) },
                            label: { Text("Reset (to startup)") }
                        )
                    }
                }
            }
            .fullScreenCover(
                isPresented: store.bindingFor(.history),
                content: {
                    NavigationView {
                        TransactionListView(store: store.historyStore(), tokenName: tokenName)
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") { store.send(.updateDestination(nil)) }
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

// MARK: - Store

extension StoreOf<Sandbox> {
    func historyStore() -> StoreOf<TransactionList> {
        self.scope(
            state: \.transactionListState,
            action: \.transactionList
        )
    }
}

// MARK: - Bindings

extension StoreOf<Sandbox> {
    func bindingFor(_ destination: Sandbox.State.Destination) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.destination == destination },
            set: { self.send(.updateDestination($0 ? destination : nil)) }
        )
    }
}

// MARK: - PlaceHolders

extension Sandbox.State {
    public static var placeholder: Self {
        .init(
            transactionListState: .placeholder,
            destination: nil
        )
    }
    
    public static var initial: Self {
        .init(
            transactionListState: .initial,
            destination: nil
        )
    }
}

extension StoreOf<Sandbox> {
    public static var placeholder: StoreOf<Sandbox> {
        StoreOf<Sandbox>(
            initialState: Sandbox.State(
                transactionListState: .placeholder,
                destination: nil
            )
        ) {
            Sandbox()
        }
    }
}
