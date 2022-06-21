//
//  TransactionRowView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 21.06.2022.
//

import SwiftUI

struct TransactionRowView: View {
    var transaction: TransactionState
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 30, height: 30, alignment: .center)
            
            VStack {
                HStack {
                    Text(transaction.status == .received ? "Unknown paid you" : "You sent to")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(transaction.status == .received ? "+" : "")
                    + Text("\(transaction.zecAmount.decimalString()) ZEC")
                }
                HStack {
                    Text(transaction.address)
                        .font(.system(size: 14))
                        .fontWeight(.thin)
                        .truncationMode(.middle)
                        .lineLimit(1)

                    Spacer(minLength: 80)
                    
                    Text("$145")
                        .font(.system(size: 14))
                        .fontWeight(.thin)
                }
            }
        }
    }
}

struct SendTransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TransactionRowView(transaction: .placeholder)
        }
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 428, height: 60))
    }
}
