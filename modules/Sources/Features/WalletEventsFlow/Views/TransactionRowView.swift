//
//  TransactionRowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 21.06.2022.
//

import SwiftUI
import ZcashLightClientKit
import Models
import Generated

public struct TransactionRowView: View {
    let transaction: TransactionState
    let tokenName: String

    public init(transaction: TransactionState, tokenName: String) {
        self.transaction = transaction
        self.tokenName = tokenName
    }
    
    public var body: some View {
        ZStack {
            icon
            
            HStack {
                VStack(alignment: .leading) {
                    Text(operationTitle)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 16)
                        )
                        .foregroundColor(Asset.Colors.primary.color)
                    
                    Text("\(transaction.date?.asHumanReadable() ?? L10n.General.dateNotAvailable)")
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 16)
                        )
                        .foregroundColor(Asset.Colors.primary.color)
                        .opacity(0.5)
                }

                Spacer()

                Group {
                    Text(transaction.unarySymbol)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 16)
                        )
                        .foregroundColor(Asset.Colors.primary.color)
                    + Text(L10n.balance(transaction.zecAmount.decimalString(), tokenName))
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 16)
                        )
                        .foregroundColor(Asset.Colors.primary.color)
                }
                .padding(.trailing, 30)
            }
            .padding(.leading, 80)
        }
        .frame(height: 60)
    }
}

extension TransactionRowView {
    var operationTitle: String {
        switch transaction.status {
        case .paid:
            return L10n.Transaction.sent
        case .received:
            return L10n.Transaction.received
        case .failed:
            // TODO: [#392] final text to be provided (https://github.com/zcash/secant-ios-wallet/issues/392)
            return L10n.Transaction.failed
        case .sending:
            return L10n.Transaction.sending
        case .receiving:
            return L10n.Transaction.receiving
        }
    }
    
    var icon: some View {
        let inTransaction = transaction.status == .received || transaction.status == .receiving
        return HStack {
            switch transaction.status {
            case .paid, .received, .sending, .receiving:
                Image(systemName: "envelope.fill")
                    .resizable()
                    .frame(width: 16, height: 12)
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(10)
                    .padding(.leading, 14)
            case .failed:
                // TODO: [#392] final icon to be provided (https://github.com/zcash/secant-ios-wallet/issues/392)
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.red)
                    .padding(15)
            }
            
            Spacer()
        }
        .padding(.leading, 15)
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRowView(
            transaction:
                .init(
                    zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                    fee: Zatoshi(10),
                    id: "2",
                    status: .paid(success: true),
                    timestamp: 1234567,
                    zecAmount: Zatoshi(123_000_000)
                ),
            tokenName: "ZEC"
        )
        .applyScreenBackground()
        .previewLayout(.fixed(width: 428, height: 60))

        TransactionRowView(
            transaction:
                .init(
                    zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                    fee: Zatoshi(10),
                    id: "2",
                    status: .failed,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(123_000_000)
                ),
            tokenName: "ZEC"
        )
        .applyScreenBackground()
        .previewLayout(.fixed(width: 428, height: 60))

        TransactionRowView(
            transaction:
                .init(
                    zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                    fee: Zatoshi(10),
                    id: "2",
                    status: .sending,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(123_000_000)
                ),
            tokenName: "ZEC"
        )
        .applyScreenBackground()
        .previewLayout(.fixed(width: 428, height: 60))

        TransactionRowView(
            transaction:
                .init(
                    zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                    fee: Zatoshi(10),
                    id: "2",
                    status: .received,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(123_000_000)
                ),
            tokenName: "ZEC"
        )
        .applyScreenBackground()
        .previewLayout(.fixed(width: 428, height: 60))
    }
}
