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
    let store: StoreOf<TransactionList>
    let data: RedactableString
    
    public init(store: StoreOf<TransactionList>, data: RedactableString) {
        self.store = store
        self.data = data
    }
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.copyToPastboard(data))
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
}

#Preview {
    TapToCopyTransactionDataView(
        store: .placeholder,
        data: "something to copy".redacted
    )
}
