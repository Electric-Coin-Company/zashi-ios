import SwiftUI
import ComposableArchitecture
import StoreKit
import Generated
import TransactionList
import Settings
import UIComponents
import SyncProgress
import Utils
import Models

public struct HomeView: View {
    let store: HomeStore
    let tokenName: String
    
    public init(store: HomeStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                balance(viewStore)

                if viewStore.isRestoringWallet {
                    SyncProgressView(
                        store: store.scope(
                            state: \.syncProgressState,
                            action: HomeReducer.Action.syncProgress
                        )
                    )
                    .frame(height: 94)
                    .frame(maxWidth: .infinity)
                    .background(Asset.Colors.shade92.color)
                }
                
                TransactionListView(store: store.historyStore(), tokenName: tokenName)
            }
            .applyScreenBackground()
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.canRequestReview) { canRequestReview in
                if canRequestReview {
                    if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: currentScene)
                    }
                    viewStore.send(.reviewRequestFinished)
                }
            }
            .onDisappear { viewStore.send(.onDisappear) }
            .alert(store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            ))
            .navigationLinkEmpty(
                isActive: viewStore.bindingForDestination(.notEnoughFreeDiskSpace),
                destination: { NotEnoughFreeSpaceView(viewStore: viewStore) }
            )
        }
        .task { await store.send(.restoreWalletTask).finish() }
    }
}

// MARK: - Buttons

extension HomeView {
    func balance(_ viewStore: HomeViewStore) -> some View {
        VStack(spacing: 0) {
            Button {
                viewStore.send(.balanceBreakdown)
            } label: {
                BalanceWithIconView(balance: viewStore.totalBalance)
            }
            .padding(.top, 40)

            if viewStore.migratingDatabase {
                Text(L10n.Home.migratingDatabases)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .padding(.top, 10)
                    .padding(.bottom, 30)
            } else {
                AvailableBalanceView(
                    balance: viewStore.shieldedBalance,
                    tokenName: tokenName
                )
                .accessDebugMenuWithHiddenGesture {
                    viewStore.send(.debugMenuStartup)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .foregroundColor(Asset.Colors.primary.color)
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store:
                    HomeStore(
                        initialState:
                                .init(
                                    scanState: .initial,
                                    shieldedBalance: .zero,
                                    synchronizerStatusSnapshot: .initial,
                                    syncProgressState: .init(
                                        lastKnownSyncPercentage: Float(0.43),
                                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                                        syncStatusMessage: "Syncing"
                                    ),
                                    totalBalance: .zero,
                                    transactionListState: .initial,
                                    walletConfig: .initial
                                )
                    ) {
                        HomeReducer(networkType: .testnet)
                    },
                tokenName: "ZEC"
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Text("M")
            )
            .zashiTitle {
                Text("Title")
            }
        }
    }
}
