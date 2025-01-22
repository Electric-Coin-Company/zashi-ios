//
//  TransactionRowView.swift
//
//
//  Created by Lukáš Korba on 05.11.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Models
import UIComponents

struct TransactionRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let store: StoreOf<TransactionList>
    let transaction: TransactionState
    let isLatestTransaction: Bool
    let tokenName: String

    init(
        store: StoreOf<TransactionList>,
        transaction: TransactionState,
        tokenName: String = "ZEC",
        isLatestTransaction: Bool = false
    ) {
        self.store = store
        self.transaction = transaction
        self.tokenName = tokenName
        self.isLatestTransaction = isLatestTransaction
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 12)
                    .opacity(isLatestTransaction ? 0.0 : 1.0)
                
                HStack(spacing: 0) {
                    transationIcon()
                        .zImage(size: 20, style: Design.Text.tertiary)
                        .background {
                            Circle()
                                .frame(width: 40, height: 40)
                                .zForegroundColor(Design.Surfaces.bgSecondary)
                        }
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 16)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text(transaction.title)
                                .zFont(.semiBold, size: 14, style: Design.Text.primary)
                            
                            if transaction.zAddress == nil && !transaction.hasTransparentOutputs {
                                Asset.Assets.shieldTick.image
                                    .zImage(size: 16, style: Design.Text.tertiary)
                                    .padding(.leading, 4)
                            }
                        }

                        Text(transaction.daysAgo)
                            .font(.custom(FontFamily.Inter.regular.name, size: 13))
                            .foregroundColor(Asset.Colors.shade47.color)
                    }

                    Spacer()
                    
                    balanceView()
                }
                .screenHorizontalPadding()
            }
            .padding(.bottom, 12)
        }
    }

    func transationIcon() -> Image {
        if transaction.isShieldingTransaction {
            return Asset.Assets.Icons.switchHorizontal.image
        } else if transaction.isSentTransaction {
            return Asset.Assets.Icons.sent.image
        } else {
            return Asset.Assets.Icons.received.image
        }
    }

    @ViewBuilder private func balanceView() -> some View {
        Group {
            Text(transaction.isSpending ? "- " : "+ ")
            + Text(store.isSensitiveContentHidden
                 ?  L10n.General.hideBalancesMost
                 : transaction.zecAmount.decimalString()
            )
            + Text(" \(tokenName)")
        }
        .zFont(size: 14, style: Design.Text.primary)
        .minimumScaleFactor(0.1)
        .lineLimit(1)
    }
}

#Preview {
    VStack(spacing: 0) {
        TransactionRowView(
            store: .placeholder,
            transaction: .mockedFailed
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedFailedReceive
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedSent
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedReceived
        )
        .listRowSeparator(.hidden)
        
        TransactionRowView(
            store: .placeholder,
            transaction: .mockedSending
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedShielded
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            store: .placeholder,
            transaction: .mockedReceiving
        )
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

