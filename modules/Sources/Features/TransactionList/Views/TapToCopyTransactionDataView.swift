//
//  TapToCopyTransactionDataView.swift
//  
//
//  Created by Lukáš Korba on 10.11.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import Utils

struct TapToCopyTransactionDataView: View {
    let viewStore: TransactionListViewStore
    let data: RedactableString
    
    public init(viewStore: TransactionListViewStore, data: RedactableString) {
        self.viewStore = viewStore
        self.data = data
    }
    
    var body: some View {
        Button {
            viewStore.send(.copyToPastboard(data))
        } label: {
            HStack {
                Asset.Assets.copy.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 11, height: 11)
                    .foregroundColor(Asset.Colors.primary.color)

                Text(L10n.General.tapToCopy)
                    .font(.custom(FontFamily.Inter.regular.name, size: 13))
                    .foregroundColor(Asset.Colors.shade47.color)
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    TapToCopyTransactionDataView(
        viewStore: ViewStore(.placeholder, observe: { $0 }),
        data: "something to copy".redacted
    )
}
