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
    @Environment(\.colorScheme) private var colorScheme
    let store: StoreOf<TransactionList>

    let messages: [String]?
    let isSpending: Bool
    let isFailed: Bool

    public init(
        store: StoreOf<TransactionList>,
        messages: [String]?,
        isSpending: Bool,
        isFailed: Bool = false
    ) {
        self.store = store
        self.messages = messages
        self.isSpending = isSpending
        self.isFailed = isFailed
    }
    
    var body: some View {
        WithPerceptionTracking {
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
                                    Design.Utility.ErrorRed._600.color(colorScheme)
                                    : Asset.Colors.primary.color
                                )
                                .conditionalStrikethrough(isFailed)
                                .padding()
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Design.Surfaces.strokePrimary.color(colorScheme))
                        }
                        
                        if store.featureFlags.selectText {
                            HStack(spacing: 0) {
                                TapToCopyTransactionDataView(store: store, data: memoTexts[index].redacted)
                                
                                Button {
                                    store.send(.selectText(memoTexts[index]))
                                } label: {
                                    HStack {
                                        Asset.Assets.Icons.textInput.image
                                            .zImage(size: 16, style: Design.Btns.Tertiary.fg)
                                        
                                        Text(L10n.Transaction.selectText)
                                            .zFont(.semiBold, size: 14, style: Design.Btns.Tertiary.fg)
                                    }
                                }
                                .buttonStyle(.borderless)
                                .padding(.leading, 24)
                            }
                        } else {
                            TapToCopyTransactionDataView(store: store, data: memoTexts[index].redacted)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.bottom, 7)
                .padding(.vertical, 10)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        MessageView(
            store: .placeholder,
            messages: ["Test"],
            isSpending: true
        )
        .padding(.bottom, 50)

        MessageView(
            store: .placeholder,
            messages: ["Test"],
            isSpending: true,
            isFailed: true
        )
        .padding(.bottom, 50)

        MessageView(
            store: .placeholder,
            messages: ["Test"],
            isSpending: false
        )

        MessageView(
            store: .placeholder,
            messages: nil,
            isSpending: false
        )
    }
}
