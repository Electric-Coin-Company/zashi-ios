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

public struct TransactionRowView: View {
    @Environment(\.colorScheme) private var colorScheme

    let transaction: TransactionState
    let divider: Bool
    @Shared(.appStorage(.sensitiveContent)) var isSensitiveContentHidden = false
    let tokenName: String

    public init(
        transaction: TransactionState,
        tokenName: String = "ZEC",
        divider: Bool = false
    ) {
        self.transaction = transaction
        self.tokenName = tokenName
        self.divider = divider
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                Divider()
                    .padding(.horizontal, 4)
                    .padding(.bottom, 12)
                    .opacity(divider ? 0.0 : 1.0)
                
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
            if isSensitiveContentHidden {
                Text(L10n.General.hideBalancesMost)
            } else {
                Text(transaction.isSpending ? "- " : "+ ")
                + Text(transaction.zecAmount.decimalString())
                + Text(" \(tokenName)")
            }
        }
        .zFont(size: 14, style: Design.Text.primary)
        .minimumScaleFactor(0.1)
        .lineLimit(1)
    }
}

#Preview {
    VStack(spacing: 0) {
        TransactionRowView(
            transaction: .mockedFailed
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            transaction: .mockedFailedReceive
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            transaction: .mockedSent
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            transaction: .mockedReceived
        )
        .listRowSeparator(.hidden)
        
        TransactionRowView(
            transaction: .mockedSending
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            transaction: .mockedShielded
        )
        .listRowSeparator(.hidden)

        TransactionRowView(
            transaction: .mockedReceiving
        )
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

