//
//  MessageView.swift
//
//
//  Created by Lukáš Korba on 05.11.2023.
//

import SwiftUI
import ComposableArchitecture

import Generated

struct MessageView: View {
    let viewStore: TransactionListViewStore

    let message: String?
    let isSpending: Bool
    let isFailed: Bool

    public init(
        viewStore: TransactionListViewStore,
        message: String?,
        isSpending: Bool,
        isFailed: Bool = false
    ) {
        self.viewStore = viewStore
        self.message = message
        self.isSpending = isSpending
        self.isFailed = isFailed
    }
    
    var body: some View {
        if let memoText = message {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.TransactionList.messageTitle)
                    .font(.custom(FontFamily.Inter.medium.name, size: 13))
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear.frame(height: 0)
                    
                    Text(memoText)
                        .font(.custom(FontFamily.Inter.regular.name, size: 13))
                        .foregroundColor(
                            isFailed ?
                            Asset.Colors.error.color
                            : Asset.Colors.primary.color
                        )
                        .conditionalStrikethrough(isFailed)
                        .padding()
                }
                .messageShape(
                    filled: !isSpending
                    ? Asset.Colors.messageBcgReceived.color
                    : nil,
                    orientation: !isSpending
                    ? .right
                    : .left
                )
                .padding(.bottom, 20)

                TapToCopyTransactionDataView(viewStore: viewStore, data: memoText.redacted)
            }
            .padding(.bottom, 7)
            .padding(.vertical, 10)
        } else {
            Text(L10n.TransactionList.noMessageIncluded)
                .font(.custom(FontFamily.Inter.regular.name, size: 13))
                .foregroundColor(Asset.Colors.primary.color)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        MessageView(viewStore: ViewStore(.placeholder, observe: { $0 }), message: "Test", isSpending: true)
            .padding(.bottom, 50)

        MessageView(viewStore: ViewStore(.placeholder, observe: { $0 }), message: "Test", isSpending: true, isFailed: true)
            .padding(.bottom, 50)

        MessageView(viewStore: ViewStore(.placeholder, observe: { $0 }), message: "Test", isSpending: false)

        MessageView(viewStore: ViewStore(.placeholder, observe: { $0 }), message: nil, isSpending: false)
    }
}
