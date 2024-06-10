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
import WalletBalances
import WalletStatusPanel

public struct HomeView: View {
    let store: HomeStore
    let tokenName: String
    
    @State var walletStatus = WalletStatus.none

    public init(store: HomeStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: HomeReducer.Action.walletBalances
                    ),
                    tokenName: tokenName,
                    couldBeHidden: true
                )
                .padding(.top, 1)

                if walletStatus == .restoring {
                    SyncProgressView(
                        store: store.scope(
                            state: \.syncProgressState,
                            action: HomeReducer.Action.syncProgress
                        )
                    )
                    .frame(height: 94)
                    .frame(maxWidth: .infinity)
                    .background(Asset.Colors.syncProgresBcg.color)
                    .padding(.top, 7)
                }
                
                TransactionListView(store: store.historyStore(), tokenName: tokenName)
            }
            .walletStatusPanel(restoringStatus: $walletStatus)
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
        }
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
                                    syncProgressState: .init(
                                        lastKnownSyncPercentage: Float(0.43),
                                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                                        syncStatusMessage: "Syncing"
                                    ),
                                    transactionListState: .placeholder,
                                    walletBalancesState: .initial,
                                    walletConfig: .initial
                                )
                    ) {
                        HomeReducer()
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
