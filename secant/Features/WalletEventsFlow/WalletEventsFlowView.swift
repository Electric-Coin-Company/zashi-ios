import SwiftUI
import ComposableArchitecture

struct WalletEventsFlowView: View {
    let store: WalletEventsFlowStore
    
    var body: some View {
        return WithViewStore(store) { viewStore in
            List {
                walletEventsList(with: viewStore)
            }
            .navigationTitle("transactions.title")
            .listStyle(.plain)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear(perform: { viewStore.send(.onDisappear) })
            .navigationLinkEmpty(isActive: viewStore.bindingForSelectedWalletEvent(viewStore.selectedWalletEvent)) {
                viewStore.selectedWalletEvent?.detailView(store)
            }
        }
    }
}

extension WalletEventsFlowView {
    func walletEventsList(with viewStore: WalletEventsFlowViewStore) -> some View {
        ForEach(viewStore.walletEvents) { walletEvent in
            walletEvent.rowView(viewStore)
                .onTapGesture {
                    viewStore.send(.updateDestination(.showWalletEvent(walletEvent)))
                }
                .listRowInsets(EdgeInsets())
                .frame(height: 60)
        }
    }
}

// MARK: - Previews

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletEventsFlowView(store: .placeholder)
                .preferredColorScheme(.light)
        }
    }
}
