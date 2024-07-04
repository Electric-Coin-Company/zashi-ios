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
    let store: StoreOf<TransactionList>
    let transaction: TransactionState
    let isLatestTransaction: Bool
    
    init(
        store: StoreOf<TransactionList>,
        transaction: TransactionState,
        isLatestTransaction: Bool = false
    ) {
        self.store = store
        self.transaction = transaction
        self.isLatestTransaction = isLatestTransaction
    }
    
    var body: some View {
        WithPerceptionTracking {
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
                                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                                    .foregroundColor(Asset.Colors.primary.color)
                                
                                Spacer(minLength: 100)
                            }
                            .padding(.horizontal, 60)
                            .padding(.bottom, 5)
                            
                            TapToCopyTransactionDataView(store: store, data: transaction.address.redacted)
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
            Asset.Assets.surroundedShield.image
                .renderingMode(.template)
                .resizable()
                .frame(width: 17, height: 13)
                .foregroundColor(Asset.Colors.primary.color)
        } else if !transaction.isAddressExpanded {
            Button {
                store.send(.transactionAddressExpandRequested(transaction.id))
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
            strikethrough: transaction.status == .failed,
            couldBeHidden: true
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
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(Asset.Colors.primary.color)

            case .received, .receiving:
                if transaction.isUnread {
                    Asset.Assets.flyReceivedFilled.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 17, height: 11)
                        .foregroundColor(Asset.Colors.primaryTint.color)
                } else {
                    Asset.Assets.flyReceived.image
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 17, height: 11)
                        .foregroundColor(Asset.Colors.primary.color)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedFailed
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedFailedReceive
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedSent
        )
        .listRowSeparator(.hidden)

        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedReceived
        )
        .listRowSeparator(.hidden)
        
        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedSending
        )
        .listRowSeparator(.hidden)
        
        TransactionHeaderView(
            store: .placeholder,
            transaction: .mockedReceiving
        )
        .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}

