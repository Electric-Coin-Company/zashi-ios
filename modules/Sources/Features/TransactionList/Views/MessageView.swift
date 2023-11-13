//
//  MessageView.swift
//
//
//  Created by Lukáš Korba on 05.11.2023.
//

import SwiftUI
import Generated

struct MessageView: View {
    let message: String?
    let isSpending: Bool
    let isFailed: Bool

    public init(
        message: String?,
        isSpending: Bool,
        isFailed: Bool = false
    ) {
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
                    
                    if isFailed {
                        Text(memoText)
                            .font(.custom(FontFamily.Inter.bold.name, size: 13))
                            .foregroundColor(Asset.Colors.error.color)
                            .strikethrough()
                            .padding()
                    } else {
                        Text(memoText)
                            .font(.custom(FontFamily.Inter.bold.name, size: 13))
                            .padding()
                    }
                }
                .messageShape(
                    filled: !isSpending
                    ? Asset.Colors.messageBcgReceived.color
                    : nil,
                    orientation: !isSpending
                    ? .right
                    : .left
                )
            }
            .padding(.bottom, 7)
            .padding(.vertical, 10)
        } else {
            Text(L10n.TransactionList.noMessageIncluded)
                .font(.custom(FontFamily.Inter.italic.name, size: 13))
                .foregroundColor(Asset.Colors.shade47.color)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        MessageView(message: "Test", isSpending: true)
            .padding(.bottom, 50)

        MessageView(message: "Test", isSpending: true, isFailed: true)
            .padding(.bottom, 50)

        MessageView(message: "Test", isSpending: false)
    }
}
