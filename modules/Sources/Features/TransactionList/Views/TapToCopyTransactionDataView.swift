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
                        .zImage(size: 11, style: Design.Btns.Tertiary.fg)
                    
                    Text(L10n.General.tapToCopy)
                        .zFont(.semiBold, size: 14, style: Design.Btns.Tertiary.fg)
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
