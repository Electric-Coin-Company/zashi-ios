//
//  TransactionSendingView.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import Generated
import UIComponents

public struct TransactionSendingView: View {
    let viewStore: SendFlowViewStore
    let tokenName: String

    public init(viewStore: SendFlowViewStore, tokenName: String) {
        self.viewStore = viewStore
        self.tokenName = tokenName
    }

    public var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                Text(L10n.Send.sendingTo(viewStore.amount.decimalString(), tokenName))
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)

                Text(viewStore.address)
                    .truncationMode(.middle)
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                    .lineLimit(1)

                Spacer()
            }
        }
        .applyScreenBackground()
        .navigationBarHidden(true)
        .navigationLinkEmpty(
            isActive: viewStore.bindingForSuccess,
            destination: { TransactionSent(viewStore: viewStore) }
        )
        .navigationLinkEmpty(
            isActive: viewStore.bindingForFailure,
            destination: { TransactionFailed(viewStore: viewStore) }
        )
    }
}

// MARK: - Previews

struct TransactionSendingView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionSendingView(viewStore: ViewStore(SendFlowStore.placeholder), tokenName: "ZEC")
    }
}
