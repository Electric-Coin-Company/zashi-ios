//
//  BalanceBreakdownView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Generated
import PartialProposalError
import UIComponents
import Utils
import Models
import BalanceFormatter
import SyncProgress
import WalletBalances

public struct BalanceBreakdownView: View {
    let store: BalanceBreakdownStore
    let tokenName: String
    
    public init(store: BalanceBreakdownStore, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ScrollView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                WalletBalancesView(
                    store: store.scope(
                        state: \.walletBalancesState,
                        action: BalanceBreakdownReducer.Action.walletBalances
                    ),
                    tokenName: tokenName,
                    underlinedAvailableBalance: false
                )

                Asset.Colors.primary.color
                    .frame(height: 1)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 10, trailing: 30))
                
                balancesBlock(viewStore)
                
                transparentBlock(viewStore)
                    .frame(minHeight: 166)
                    .padding(.horizontal, viewStore.isHintBoxVisible ? 15 : 30)
                    .background {
                        Asset.Colors.shade92.color
                    }
                    .padding(.horizontal, 30)

                if viewStore.isRestoringWallet {
                    Text(L10n.Balances.restoringWalletWarning)
                        .font(.custom(FontFamily.Inter.medium.name, size: 10))
                        .foregroundColor(Asset.Colors.error.color)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                }
                
                SyncProgressView(
                    store: store.scope(
                        state: \.syncProgressState,
                        action: BalanceBreakdownReducer.Action.syncProgress
                    )
                )
                .padding(.top, viewStore.isRestoringWallet ? 0 : 40)
                .padding(.bottom, 25)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForPartialProposalError,
                    destination: {
                        PartialProposalErrorView(store: store.partialProposalErrorStore())
                    }
                )
            }
        }
        .padding(.vertical, 1)
        .applyScreenBackground()
        .alert(
            store: store.scope(
                state: \.$alert,
                action: { .alert($0) }
            )
        )
        .task { await store.send(.restoreWalletTask).finish() }
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
    }
}

extension BalanceBreakdownView {
    @ViewBuilder func balancesBlock(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Text(L10n.Balances.spendableBalance.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.shieldedBalance,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                
                Asset.Assets.shield.image
                    .resizable()
                    .frame(width: 11, height: 14)
                    .padding(.leading, 10)
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.changePending.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.changePending,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)
                .padding(.trailing, viewStore.changePending.amount > 0 ? 0 : 21)

                if viewStore.changePending.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
            
            HStack(spacing: 0) {
                Text(L10n.Balances.pendingTransactions.uppercased())
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.pendingTransactions,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)
                .padding(.trailing, viewStore.pendingTransactions.amount > 0 ? 0 : 21)

                if viewStore.pendingTransactions.amount > 0 {
                    progressViewLooping()
                        .padding(.leading, 10)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
    }
    
    @ViewBuilder func transparentBlock(_ viewStore: BalanceBreakdownViewStore) -> some View {
        if viewStore.isHintBoxVisible {
            transparentBlockHintBox(viewStore)
                .frame(maxWidth: .infinity)
        } else {
            transparentBlockShielding(viewStore)
        }
    }

    @ViewBuilder private func transparentBlockShielding(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack {
            HStack(spacing: 0) {
                Button {
                    viewStore.send(.updateHintBoxVisibility(true))
                } label: {
                    HStack(spacing: 3) {
                        Text(L10n.Balances.transparentBalance.uppercased())
                            .font(.custom(FontFamily.Inter.regular.name, size: 13))
                            .fixedSize()

                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 11, height: 11)
                            .padding(.bottom, 10)
                    }
                    .foregroundColor(Asset.Colors.primary.color)
                }
                
                Spacer()
                
                ZatoshiRepresentationView(
                    balance: viewStore.transparentBalance,
                    fontName: FontFamily.Archivo.semiBold.name,
                    mostSignificantFontSize: 16,
                    leastSignificantFontSize: 8,
                    format: .expanded
                )
                .foregroundColor(Asset.Colors.shade47.color)
            }
            .padding(.bottom, 10)

            Button {
                viewStore.send(.shieldFunds)
            } label: {
                if viewStore.isShieldingFunds {
                    HStack(spacing: 10) {
                        Text(L10n.Balances.shieldingInProgress.uppercased())
                            .font(.custom(FontFamily.Inter.medium.name, size: 10))
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Asset.Colors.primary.color))
                    }
                } else {
                    Text(L10n.Balances.shieldButtonTitle.uppercased())
                        .font(.custom(FontFamily.Inter.medium.name, size: 10))
                }
            }
            .zcashStyle(
                minWidth: nil,
                height: 38,
                shadowOffset: 6
            )
            .padding(.bottom, 15)
            .disabled(!viewStore.isShieldableBalanceAvailable || viewStore.isShieldingFunds)
            
            Text("(\(ZatoshiStringRepresentation.feeFormat))")
                .font(.custom(FontFamily.Inter.semiBold.name, size: 11))
        }
    }

    @ViewBuilder private func transparentBlockHintBox(_ viewStore: BalanceBreakdownViewStore) -> some View {
        VStack {
            Text(L10n.Balances.HintBox.message)
                .font(.custom(FontFamily.Inter.regular.name, size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(Asset.Colors.primary.color)
            
            Spacer()
            
            Button {
                viewStore.send(.updateHintBoxVisibility(false))
            } label: {
                Text(L10n.Balances.HintBox.dismiss.uppercased())
                    .font(.custom(FontFamily.Inter.semiBold.name, size: 10))
                  .underline()
                  .foregroundColor(Asset.Colors.primary.color)
            }
        }
        .hintBoxShape()
        .padding(.vertical, 15)
    }
    
    @ViewBuilder func progressViewLooping() -> some View {
        ProgressView()
            .scaleEffect(0.7)
            .frame(width: 11, height: 14)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        BalanceBreakdownView(
            store: BalanceBreakdownStore(
                initialState: BalanceBreakdownReducer.State(
                    autoShieldingThreshold: Zatoshi(1_000_000),
                    changePending: Zatoshi(25_234_000),
                    isShieldingFunds: true,
                    isHintBoxVisible: true,
                    partialProposalErrorState: .initial,
                    pendingTransactions: Zatoshi(25_234_000),
                    syncProgressState: .init(
                        lastKnownSyncPercentage: 0.43,
                        synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                        syncStatusMessage: "Syncing"
                    ),
                    walletBalancesState: .initial
                )
            ) {
                BalanceBreakdownReducer()
            },
            tokenName: "ZEC"
        )
    }
    .navigationViewStyle(.stack)
}
