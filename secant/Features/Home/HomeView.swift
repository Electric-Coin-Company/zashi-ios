import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeReducer.State, HomeReducer.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    profileButton(viewStore)
                    
                    Spacer()
                }
                
                balance(viewStore)

                Spacer()

                sendButton(viewStore)
                
                Button {
                    viewStore.send(.updateDestination(.transactionHistory))
                } label: {
                    Text("See transaction history")
                }
            }
            .applyScreenBackground()
            .navigationBarHidden(true)
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
            .fullScreenCover(isPresented: viewStore.bindingForDestination(.balanceBreakdown)) {
                BalanceBreakdownView(store: store.balanceBreakdownStore())
            }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.notEnoughFreeDiskSpace),
                destination: { NotEnoughFreeSpaceView(viewStore: viewStore) }
            )
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.transactionHistory),
                destination: { WalletEventsFlowView(store: store.historyStore()) }
            )
        }
    }
}

// MARK: - Buttons

extension HomeView {
    func profileButton(_ viewStore: HomeViewStore) -> some View {
        Image(Asset.Assets.Icons.profile.name)
            .resizable()
            .frame(width: 60, height: 60)
            .padding(.trailing, 15)
            .navigationLink(
                isActive: viewStore.bindingForDestination(.profile),
                destination: {
                    ProfileView(store: store.profileStore())
                }
            )
    }

    func sendButton(_ viewStore: HomeViewStore) -> some View {
        Text("Send")
            .shadow(color: Asset.Colors.Buttons.buttonsTitleShadow.color, radius: 2, x: 0, y: 2)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
            .foregroundColor(Asset.Colors.Text.activeButtonText.color)
            .background(Asset.Colors.Buttons.activeButton.color)
            .cornerRadius(12)
            .frame(height: 60)
            .padding(.horizontal, 50)
            .neumorphicButton()
            .navigationLink(
                isActive: viewStore.bindingForDestination(.send),
                destination: {
                    SendFlowView(store: store.sendStore())
                }
            )
            .padding(.bottom, 30)
    }
    
    func balance(_ viewStore: HomeViewStore) -> some View {
        Group {
            Button {
                viewStore.send(.updateDestination(.balanceBreakdown))
            } label: {
                Text("$\(viewStore.shieldedBalance.data.total.decimalString())")
                    .font(.custom(FontFamily.Zboto.regular.name, size: 40))
                    .foregroundColor(Asset.Colors.Text.balanceText.color)
            }
            
            Text("$\(viewStore.totalCurrencyBalance.decimalString())")
                .font(.custom(FontFamily.Rubik.regular.name, size: 13))
                .opacity(0.6)
            
            Text("\(viewStore.synchronizerStatusSnapshot.message)")
                .accessDebugMenuWithHiddenGesture {
                    viewStore.send(.debugMenuStartup)
                }
        }
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(store: .placeholder)
        }

        NavigationView {
            HomeView(store: .placeholder)
                .preferredColorScheme(.dark)
        }
    }
}
