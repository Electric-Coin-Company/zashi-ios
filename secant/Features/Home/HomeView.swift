import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: Store<HomeReducer.State, HomeReducer.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    scanButton(viewStore)
                    
                    profileButton(viewStore)

                    circularArea(viewStore, proxy.size)

                    sendButton(viewStore)
                    
                    if proxy.size.height > 0 {
                        Drawer(overlay: viewStore.bindingForDrawer(), maxHeight: proxy.size.height) {
                            WalletEventsFlowView(store: store.historyStore())
                                .applyScreenBackground()
                        }
                    }
                }
                .applyScreenBackground()
                .navigationBarHidden(true)
                .onAppear(perform: { viewStore.send(.onAppear) })
                .onDisappear(perform: { viewStore.send(.onDisappear) })
                .fullScreenCover(isPresented: viewStore.bindingForDestination(.balanceBreakdown)) {
                    BalanceBreakdownView(store: store.balanceBreakdownStore())
                }
            }
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.notEnoughFreeDiskSpace),
                destination: { NotEnoughFreeSpaceView(viewStore: viewStore) }
            )
        }
    }
}

// MARK: - Buttons

extension HomeView {
    func profileButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            HStack {
                Spacer()
                
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
            
            Spacer()
        }
    }

    func sendButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            Spacer()
            
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

            Spacer()
        }
    }

    func scanButton(_ viewStore: HomeViewStore) -> some View {
        VStack {
            HStack {
                Image(Asset.Assets.Icons.qrCode.name)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 7)
                    .padding(.leading, 22)
                    .navigationLink(
                        isActive: viewStore.bindingForDestination(.scan),
                        destination: {
                            ScanView(store: store.scanStore())
                        }
                    )
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    func circularArea(_ viewStore: HomeViewStore, _ size: CGSize) -> some View {
        VStack {
            ZStack {
                CircularProgress(
                    outerCircleProgress: viewStore.isDownloading ? 0 : viewStore.synchronizerStatusSnapshot.progress,
                    innerCircleProgress: viewStore.isDownloading ? viewStore.synchronizerStatusSnapshot.progress : 1,
                    maxSegments: viewStore.requiredTransactionConfirmations,
                    innerCircleHidden: viewStore.isUpToDate
                )
                .frame(width: size.width * 0.65, height: size.width * 0.65)
                .padding(.top, 50)
                
                VStack {
                    Button {
                        viewStore.send(.updateDestination(.balanceBreakdown))
                    } label: {
                        Text("$\(viewStore.shieldedBalance.total.decimalString())")
                            .font(.custom(FontFamily.Zboto.regular.name, size: 40))
                            .foregroundColor(Asset.Colors.Text.balanceText.color)
                            .padding(.top, 80)
                    }

                    Text("$\(viewStore.totalCurrencyBalance.decimalString())")
                        .font(.custom(FontFamily.Rubik.regular.name, size: 13))
                        .opacity(0.6)
                        .padding(.bottom, 50)

                    Text("\(viewStore.synchronizerStatusSnapshot.message)")
                        .accessDebugMenuWithHiddenGesture {
                            viewStore.send(.debugMenuStartup)
                        }
                }
            }
            
            Spacer()
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
