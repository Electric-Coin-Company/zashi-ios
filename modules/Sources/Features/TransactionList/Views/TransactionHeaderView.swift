//
//  TransactionHeaderView.swift
//
//
//  Created by Lukáš Korba on 05.11.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Models
import UIComponents

struct TransactionHeaderView: View {
    let viewStore: TransactionListViewStore
    let transaction: TransactionState
    let isLatestTransaction: Bool
    
    init(
        viewStore: TransactionListViewStore,
        transaction: TransactionState,
        isLatestTransaction: Bool = false
    ) {
        self.viewStore = viewStore
        self.transaction = transaction
        self.isLatestTransaction = isLatestTransaction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .opacity(isLatestTransaction ? 0.0 : 1.0)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 0) {
                        iconImage()

                        titleText()
                        
                        addressArea()
                        
                        Spacer(minLength: 60)
                        
                        balanceView()
                    }
                    .padding(.trailing, 30)
                    
                    if transaction.zAddress != nil && transaction.isAddressExpanded {
                        HStack {
                            Text(transaction.address)
                                .font(.custom(FontFamily.Inter.bold.name, size: 13))
                                .foregroundColor(Asset.Colors.shade47.color)

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 60)
                        .padding(.bottom, 5)
                        
                        TapToCopyTransactionDataView(viewStore: viewStore, data: transaction.address.redacted)
                            .padding(.horizontal, 60)
                            .padding(.bottom, 20)
                    }

                    Text("\(transaction.dateString ?? "")")
                        .font(.custom(FontFamily.Inter.regular.name, size: 13))
                        .foregroundColor(Asset.Colors.shade47.color)
                        .padding(.horizontal, 60)
                }
            }
        }
        .padding(.bottom, 30)
    }

    @ViewBuilder private func iconImage() -> some View {
        HStack {
            Spacer()
            
            icon
                .padding(.trailing, 10)
        }
        .frame(width: 60)
    }

    @ViewBuilder private func titleText() -> some View {
        Text(transaction.title)
            .conditionalStrikethrough(transaction.status == .failed)
            .conditionalFont(
                condition: transaction.isPending,
                true: .custom(FontFamily.Inter.boldItalic.name, size: 13),
                else: .custom(FontFamily.Inter.bold.name, size: 13)
            )
            .foregroundColor(transaction.titleColor)
            .padding(.trailing, 8)
    }

    @ViewBuilder private func addressArea() -> some View {
        if transaction.zAddress == nil {
            Asset.Assets.shield.image
                .resizable()
                .frame(width: 17, height: 13)
        } else if !transaction.isAddressExpanded {
            Button {
                viewStore.send(.transactionAddressExpandRequested(transaction.id))
            } label: {
                Text(transaction.address)
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                    .foregroundColor(Asset.Colors.shade47.color)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .disabled(!transaction.isExpanded)
        }
    }
    
    @ViewBuilder private func balanceView() -> some View {
        ZatoshiRepresentationView(
            balance: transaction.zecAmount,
            fontName: FontFamily.Inter.regular.name,
            mostSignificantFontSize: 12,
            leastSignificantFontSize: 8,
            prefixSymbol: transaction.isSpending ? .minus : .plus,
            format: transaction.isExpanded ? .expanded : .abbreviated,
            strikethrough: transaction.status == .failed
        )
        .foregroundColor(transaction.balanceColor)
    }
}

extension TransactionHeaderView {
    var icon: some View {
        HStack {
            switch transaction.status {
            case .paid, .failed, .sending:
                Asset.Assets.fly.image
                    .resizable()
                    .frame(width: 20, height: 16)

            case .received, .receiving:
                if transaction.isUnread {
                    Asset.Assets.flyReceivedFilled.image
                        .resizable()
                        .frame(width: 17, height: 11)
                } else {
                    Asset.Assets.flyReceived.image
                        .resizable()
                        .frame(width: 17, height: 11)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedFailed
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedFailedReceive
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedSent
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedReceived
        )
        .listRowSeparator(.hidden)
        
        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedSending
        )
        .listRowSeparator(.hidden)
        
        TransactionHeaderView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            transaction: .mockedReceiving
        )
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

