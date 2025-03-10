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

public struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let store: StoreOf<Home>
    let tokenName: String
    
    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<Home>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: \.walletBalances
                    ),
                    tokenName: tokenName,
                    couldBeHidden: true
                )
                .padding(.top, 1)

                if walletStatus == .restoring {
                    SyncProgressView(
                        store: store.scope(
                            state: \.syncProgressState,
                            action: \.syncProgress
                        )
                    )
                    .frame(height: 94)
                    .frame(maxWidth: .infinity)
                    .background(Asset.Colors.syncProgresBcg.color)
                    .padding(.top, 7)
                    .padding(.bottom, 20)
                }
                
                HStack(spacing: 8) {
                    button(
                        L10n.Tabs.receive,
                        icon: Asset.Assets.Icons.received.image
                    ) {
                        store.send(.receiveTapped)
                    }

                    button(
                        L10n.Tabs.send,
                        icon: Asset.Assets.Icons.sent.image
                    ) {
                        store.send(.sendTapped)
                    }

                    button(
                        "Scan",
                        icon: Asset.Assets.Icons.scan.image
                    ) {
                        store.send(.scanTapped)
                    }

                    button(
                        "More",
                        icon: Asset.Assets.Icons.dotsMenu.image
                    ) {
                        store.send(.moreTapped)
                    }
                }
                .zFont(.medium, size: 12, style: Design.Text.primary)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .screenHorizontalPadding()

                VStack(spacing: 0) {
                    if store.transactionListState.transactions.isEmpty && !store.transactionListState.isInvalidated {
                        noTransactionsView()
                    } else {
                        transactionsView()

                        TransactionListView(
                            store:
                                store.scope(
                                    state: \.transactionListState,
                                    action: \.transactionList
                                ),
                            tokenName: tokenName
                        )
                    }
                }
            }
            .navigationBarItems(
                leading:
                    walletAccountSwitcher()
            )
            .navigationBarItems(
                trailing:
                    HStack(spacing: 0) {
                        hideBalancesButton()
                        
                        settingsButton()
                    }
            )
            .walletStatusPanel()
            .applyScreenBackground()
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: store.canRequestReview) { canRequestReview in
                if canRequestReview {
                    if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: currentScene)
                    }
                    store.send(.reviewRequestFinished)
                }
            }
            .onDisappear { store.send(.onDisappear) }
            .alert(
                store:
                    store.scope(
                        state: \.$alert,
                        action: \.alert
                    )
            )
        }
    }

    @ViewBuilder func transactionsView() -> some View {
        WithPerceptionTracking {
            HStack(spacing: 0) {
                Text(L10n.TransactionHistory.title)
                    .zFont(.semiBold, size: 18, style: Design.Text.primary)
                
                Spacer()
                
                if store.transactionListState.transactions.count > TransactionList.Constants.homePageTransactionsCount {
                    Button {
                        store.send(.seeAllTransactionsTapped)
                    } label: {
                        HStack(spacing: 4) {
                            Text(L10n.TransactionHistory.seeAll)
                                .zFont(.semiBold, size: 14, style: Design.Btns.Tertiary.fg)
                            
                            Asset.Assets.chevronRight.image
                                .zImage(size: 16, style: Design.Btns.Tertiary.fg)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                        }
                    }
                }
            }
            .screenHorizontalPadding()
        }
    }

    @ViewBuilder func noTransactionsView() -> some View {
        WithPerceptionTracking {
            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<5) { _ in
                        NoTransactionPlaceholder()
                    }
                    
                    Spacer()
                }
                .overlay {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .clear, location: 0.0),
                            Gradient.Stop(color: Asset.Colors.background.color, location: 0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                
                VStack(spacing: 0) {
                    Asset.Assets.Illustrations.emptyState.image
                        .resizable()
                        .frame(width: 164, height: 164)
                        .padding(.bottom, 20)

                    Text(L10n.TransactionHistory.nothingHere)
                        .zFont(.semiBold, size: 18, style: Design.Text.primary)
                        .padding(.bottom, 8)

                    if walletStatus != .restoring {
                        Text(L10n.TransactionHistory.makeTransaction)
                            .zFont(size: 14, style: Design.Text.tertiary)
                            .padding(.bottom, 20)
                        
                        ZashiButton(
                            L10n.TransactionHistory.getSomeZec,
                            type: .tertiary,
                            infinityWidth: false
                        ) {
                            store.send(.getSomeZecTapped)
                        }
                    }
                }
                .padding(.top, 40)
            }
        }
    }
    
    private func button(_ title: String, icon: Image, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Design.Surfaces.bgSecondary.color(colorScheme))
            }
        }
    }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                store:
                    StoreOf<Home>(
                        initialState:
                                .init(
                                    syncProgressState: .init(
                                        lastKnownSyncPercentage: Float(0.43),
                                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                                        syncStatusMessage: "Syncing"
                                    ),
                                    transactionListState: .initial,
                                    walletBalancesState: .initial,
                                    walletConfig: .initial
                                )
                    ) {
                        Home()
                    },
                tokenName: "ZEC"
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Text("M")
            )
            .screenTitle("Title")
        }
    }
}

// MARK: Placeholders

extension Home.State {
    public static var initial: Self {
        .init(
            syncProgressState: .initial,
            transactionListState: .initial,
            walletBalancesState: .initial,
            walletConfig: .initial
        )
    }
}

extension Home {
    public static var placeholder: StoreOf<Home> {
        StoreOf<Home>(
            initialState: .initial
        ) {
            Home()
        }
    }

    public static var error: StoreOf<Home> {
        StoreOf<Home>(
            initialState: .init(
                syncProgressState: .initial,
                transactionListState: .initial,
                walletBalancesState: .initial,
                walletConfig: .initial
            )
        ) {
            Home()
        }
    }
}
