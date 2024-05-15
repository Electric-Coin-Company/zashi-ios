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

    let messages: [String]?
    let isSpending: Bool
    let isFailed: Bool

    public init(
        viewStore: TransactionListViewStore,
        messages: [String]?,
        isSpending: Bool,
        isFailed: Bool = false
    ) {
        self.viewStore = viewStore
        self.messages = messages
        self.isSpending = isSpending
        self.isFailed = isFailed
    }
    
    var body: some View {
        if let memoTexts = messages {
            VStack(alignment: .leading, spacing: 0) {
                Text(memoTexts.count == 1
                     ? L10n.TransactionList.messageTitle
                     : L10n.TransactionList.messageTitlePlural
                )
                .font(.custom(FontFamily.Inter.medium.name, size: 13))
                .padding(.bottom, 8)
                
                ForEach(0..<memoTexts.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(height: 0)
                        
                        Text(memoTexts[index])
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
                        border: isSpending
                        ? Asset.Colors.primary.color
                        : nil,
                        orientation: !isSpending
                        ? .right
                        : .left
                    )
                    
                    TapToCopyTransactionDataView(viewStore: viewStore, data: memoTexts[index].redacted)
                }
                .padding(.bottom, 20)
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
        MessageView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            messages: ["Test"],
            isSpending: true
        )
        .padding(.bottom, 50)

        MessageView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            messages: ["Test"],
            isSpending: true,
            isFailed: true
        )
        .padding(.bottom, 50)

        MessageView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            messages: ["Test"],
            isSpending: false
        )

        MessageView(
            viewStore: ViewStore(.placeholder, observe: { $0 }),
            messages: nil,
            isSpending: false
        )
    }
}
