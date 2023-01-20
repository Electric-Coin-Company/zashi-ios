//
//  TransactionRowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 21.06.2022.
//

import SwiftUI
import ZcashLightClientKit

struct TransactionRowView: View {
    var transaction: TransactionState
    
    var body: some View {
        ZStack {
            icon
            
            HStack {
                VStack {
                    HStack {
                        Text(operationTitle)
                            .font(.custom(FontFamily.Rubik.regular.name, size: 14))
                        
                        Spacer()
                        
                        Text(transaction.status == .received ? "+" : "")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 17))
                        + Text("\(transaction.zecAmount.decimalString()) ZEC")
                            .font(.custom(FontFamily.Rubik.regular.name, size: 17))
                    }
                    .padding(.trailing, 30)
                    
                    HStack {
                        Text(transaction.address)
                            .foregroundColor(Asset.Colors.Text.transactionRowSubtitle.color)
                            .font(.custom(FontFamily.Rubik.regular.name, size: 12))
                            .truncationMode(.middle)
                            .lineLimit(1)
                        
                        Spacer(minLength: 80)
                        
                        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
                    }
                    .padding(.trailing, 15)
                }
            }
            .padding(.leading, 80)
            
            VStack {
                Spacer()
                Rectangle()
                    .padding(.horizontal, 30)
                    .frame(height: 1, alignment: .center)
                    .foregroundColor(Asset.Colors.Text.transactionRowSubtitle.color)
            }
        }
        .frame(height: 60)
    }
}

extension TransactionRowView {
    var operationTitle: String {
        switch transaction.status {
        case .paid(success: _):
            return "You sent to"
        case .received:
            return "Unknown paid you"
        case .failed:
            // TODO: [#392] final text to be provided (https://github.com/zcash/secant-ios-wallet/issues/392)
            return "Transaction failed"
        case .pending:
            return "You are sending to"
        }
    }
    
    var icon: some View {
        HStack {
            switch transaction.status {
            case .paid(success: _), .received:
                Image(transaction.status == .received ? Asset.Assets.Icons.received.name : Asset.Assets.Icons.sent.name)
                    .resizable()
                    .frame(width: 60, height: 60)
            case .failed:
                // TODO: [#392] final icon to be provided (https://github.com/zcash/secant-ios-wallet/issues/392)
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.red)
                    .padding(15)
            case .pending:
                LottieAnimation(
                    isPlaying: true,
                    filename: "endlessCircleProgress",
                    animationType: .circularLoop
                )
                .frame(width: 60, height: 60)
                .scaleEffect(0.45)
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
                )
        )
        .preferredColorScheme(.dark)
        .applyScreenBackground()
        .previewLayout(.fixed(width: 428, height: 60))
    }
}
