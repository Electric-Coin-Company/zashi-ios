import SwiftUI
import ComposableArchitecture

struct WalletEventsFlowView: View {
    let store: WalletEventsFlowStore

    var body: some View {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear

        return WithViewStore(store) { viewStore in
            Group {
                header(with: viewStore)
                
                if viewStore.isScrollable {
                    List {
                        walletEventsList(with: viewStore)
                    }
                    .listStyle(.sidebar)
                } else {
                    walletEventsList(with: viewStore)
                        .padding(.horizontal, 32)
                }
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
        }
    }
}

extension WalletEventsFlowView {
    func walletEventsList(with viewStore: WalletEventsFlowViewStore) -> some View {
        ForEach(viewStore.walletEvents) { walletEvent in
            WithStateBinding(binding: viewStore.bindingForSelectingWalletEvent(walletEvent)) { active in
                VStack {
                    walletEvent.rowView()
                }
                .navigationLink(
                    isActive: active,
                    destination: { walletEvent.detailView() }
                )
                .foregroundColor(Asset.Colors.Text.body.color)
                .listRowBackground(Color.clear)
            }
        }
    }
    
    func header(with viewStore: WalletEventsFlowViewStore) -> some View {
        HStack(spacing: 0) {
            VStack {
                Button("Latest") {
                    viewStore.send(.updateRoute(.latest))
                }
                
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(Asset.Colors.TextField.Underline.purple.color)
            }

            VStack {
                Button("All") {
                    viewStore.send(.updateRoute(.all))
                }

                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(Asset.Colors.TextField.Underline.gray.color)
            }
        }
    }
}

// MARK: - Previews

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletEventsFlowView(store: .placeholder)
                .preferredColorScheme(.dark)
        }
    }
}
