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
import Scan
import BalanceBreakdown

public struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<Home>
    let tokenName: String
    
    @State var accountSwitchSheetHeight: CGFloat = .zero
    @State var moreSheetHeight: CGFloat = .zero
    @State var balancesSheetHeight: CGFloat = .zero

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
                        L10n.HomeScreen.scan,
                        icon: Asset.Assets.Icons.scan.image
                    ) {
                        store.send(.scanTapped)
                    }

                    button(
                        L10n.HomeScreen.more,
                        icon: Asset.Assets.Icons.dotsMenu.image
                    ) {
                        store.send(.moreTapped)
                    }
                }
                .zFont(.medium, size: 12, style: Design.Text.primary)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .screenHorizontalPadding()

//                SmartBanner(isOpen: true) {
////                    EmptyView()
//                    HStack(spacing: 0) {
//                        //VStack(alignment: .leading, spacing: 0) {
//                            Asset.Assets.infoCircle.image
//                                .zImage(size: 20, style: Design.Utility.Gray._900)
//                                .padding(.trailing, 12)
//                            //Spacer()
//                        //}
//                        
//                        VStack(alignment: .leading, spacing: 0) {
//                            Text("Wallet Backup Required")
//                                .zFont(.medium, size: 14, style: Design.Utility.Gray._900)
//                            Text("Prevent potential loss of funds")
//                                .zFont(.medium, size: 12, style: Design.Utility.Gray._700)
//                        }
//                        .lineLimit(1)
//                        
//                        Spacer()
//                        
//                        ZashiButton("Get started") {
//                            
//                        }
//                        .frame(width: 106)
//                        .padding(.trailing, 6)
//                    }
//                }
//                .padding(.bottom, 40)

//                SmartBanner()
//                    .padding(.bottom, 40)

//                SmartBanner {
//                    Text("content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger ")
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//                SmartBanner {
//                    Text("ch bigger content is much bigger content is much bigger content is much bigger content is much bigger content is much bigger ")
//                }

                //VStack(spacing: 0) {
                ScrollView {
                    if store.transactionListState.transactions.isEmpty && !store.transactionListState.isInvalidated {
                        noTransactionsView()
                            .padding(.top, 12)
                    } else {
                        VStack(spacing: 0) {
//                            noTransactionsView()
                            transactionsView()
                            
                            TransactionListView(
                                store:
                                    store.scope(
                                        state: \.transactionListState,
                                        action: \.transactionList
                                    ),
                                tokenName: tokenName,
                                scrollable: false
                            )
                        }
                        .padding(.top, 12)
                    }
                }
                //.padding(.top, 12)
            }
//            .popover(
//                isPresented:
//                    Binding(
//                        get: { store.balancesBinding },
//                        set: { store.send(.balancesBindingUpdated($0)) }
//                    )
//            ) {
//                //NavigationView {
//                    BalancesView(
//                        store:
//                            store.scope(
//                                state: \.balancesState,
//                                action: \.balances
//                            ),
//                        tokenName: tokenName
//                    )
//                //}
//            }
            .sheet(isPresented: $store.isInAppBrowserCoinbaseOn) {
                if let urlStr = store.inAppBrowserURLCoinbase, let url = URL(string: urlStr) {
                    InAppBrowserView(url: url)
                }
            }
            .sheet(isPresented: $store.isInAppBrowserKeystoneOn) {
                if let url = URL(string: store.inAppBrowserURLKeystone) {
                    InAppBrowserView(url: url)
                }
            }
            .sheet(isPresented: $store.balancesBinding) {
                balancesContent()
            }
            .sheet(isPresented: $store.accountSwitchRequest) {
                accountSwitchContent()
            }
            .sheet(isPresented: $store.moreRequest) {
                moreContent()
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
            .overlayPreferenceValue(ExchangeRateStaleTooltipPreferenceKey.self) { preferences in
                WithPerceptionTracking {
                    if store.isRateTooltipEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                Tooltip(
                                    title: L10n.Tooltip.ExchangeRate.title,
                                    desc: L10n.Tooltip.ExchangeRate.desc
                                ) {
                                    store.send(.rateTooltipTapped)
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
                            }
                        }
                    }
                }
            }
            .overlayPreferenceValue(ExchangeRateFeaturePreferenceKey.self) { preferences in
                WithPerceptionTracking {
                    if store.isRateEducationEnabled {
                        GeometryReader { geometry in
                            preferences.map {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .top, spacing: 0) {
                                        Asset.Assets.coinsSwap.image
                                            .zImage(size: 20, style: Design.Text.primary)
                                            .padding(10)
                                            .background {
                                                Circle()
                                                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                                            }
                                            .padding(.trailing, 16)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(L10n.CurrencyConversion.cardTitle)
                                                .zFont(size: 14, style: Design.Text.tertiary)
                                            
                                            Text(L10n.CurrencyConversion.title)
                                                .zFont(.semiBold, size: 16, style: Design.Text.primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                        }
                                        .padding(.trailing, 16)
                                        
                                        Spacer(minLength: 0)
                                        
                                        Button {
                                            store.send(.currencyConversionCloseTapped)
                                        } label: {
                                            Asset.Assets.buttonCloseX.image
                                                .zImage(size: 20, style: Design.HintTooltips.defaultFg)
                                        }
                                        .padding(20)
                                        .offset(x: 20, y: -20)
                                    }
                                    
                                    Button {
                                        store.send(.currencyConversionSetupTapped)
                                    } label: {
                                        Text(L10n.CurrencyConversion.cardButton)
                                            .zFont(.semiBold, size: 16, style: Design.Btns.Tertiary.fg)
                                            .frame(height: 24)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Design.Btns.Tertiary.bg.color(colorScheme))
                                            }
                                    }
                                }
                                .padding(24)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Design.Surfaces.bgPrimary.color(colorScheme))
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Design.Surfaces.strokeSecondary.color(colorScheme))
                                        }
                                }
                                .frame(width: geometry.size.width - 40)
                                .offset(x: 20, y: geometry[$0].minY + geometry[$0].height)
                            }
                        }
                    }
                }
            }
            //..walletstatusPanel()
            .applyScreenBackground()
            .onAppear {
                store.send(.onAppear)
            }
//            .popover(isPresented: $store.scanBinding) {
//                ScanView(
//                    store:
//                        store.scope(
//                            state: \.scanState,
//                            action: \.scan
//                        )
//                )
//            }
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
