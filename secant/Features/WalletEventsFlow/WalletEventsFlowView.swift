import SwiftUI
import ComposableArchitecture

struct WalletEventsFlowView: View {
    let store: WalletEventsFlowStore
    @State var flag = true
    
    var body: some View {
        return WithViewStore(store) { viewStore in
            VStack {
                header(with: viewStore)
                
                if viewStore.isScrollable {
                    List {
                        walletEventsList(with: viewStore)
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 60)
                } else {
                    walletEventsList(with: viewStore)
                }
                
                Spacer()
            }
            .onAppear(
                perform: {
                    UITableView.appearance().backgroundColor = .clear
                    UITableView.appearance().separatorColor = .clear
                    viewStore.send(.onAppear)
                }
            )
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
                .foregroundColor(Asset.Colors.Text.body.color)
                .listRowBackground(Color.clear)
        }
    }
    
    func header(with viewStore: WalletEventsFlowViewStore) -> some View {
        HStack(spacing: 0) {
            VStack {
                Button {
                    viewStore.send(.updateDestination(.latest))
                } label: {
                    Text("Latest")
                        .font(.custom(FontFamily.Rubik.regular.name, size: 18))
                }
                .frame(width: 100)
                .foregroundColor(Asset.Colors.Text.drawerTabsText.color)
                .opacity(viewStore.isScrollable ? 0.23 : 1.0)
                
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(latestUnderline(viewStore))
            }

            VStack {
                Button {
                    viewStore.send(.updateDestination(.all))
                } label: {
                    Text("All")
                        .font(.custom(FontFamily.Rubik.regular.name, size: 18))
                }
                .frame(width: 100)
                .foregroundColor(Asset.Colors.Text.drawerTabsText.color)
                .opacity(viewStore.isScrollable ? 1.0 : 0.23)

                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(allUnderline(viewStore))
            }
        }
    }
    
    private func latestUnderline(_ viewStore: WalletEventsFlowViewStore) -> Color {
        viewStore.isScrollable ? Asset.Colors.TextField.Underline.gray.color : Asset.Colors.TextField.Underline.purple.color
    }

    private func allUnderline(_ viewStore: WalletEventsFlowViewStore) -> Color {
        viewStore.isScrollable ? Asset.Colors.TextField.Underline.purple.color : Asset.Colors.TextField.Underline.gray.color
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
