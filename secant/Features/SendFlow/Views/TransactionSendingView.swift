//
//  TransactionSendingView.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct TransactionSendingView: View {
    let viewStore: SendFlowViewStore

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                Text("Send \(viewStore.amount.decimalString()) ZEC to")
                    .foregroundColor(Asset.Colors.Text.forDarkBackground.color)

                Text(viewStore.address)
                    .truncationMode(.middle)
                    .foregroundColor(Asset.Colors.Text.forDarkBackground.color)
                    .lineLimit(1)

                LottieAnimation(
                    isPlaying: true,
                    filename: "sendingTransaction",
                    animationType: .circularLoop
                )
                .frame(height: 48)

                Spacer()
            }
        }
        .applyAmberScreenBackground()
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
        TransactionSendingView(viewStore: ViewStore(SendFlowStore.placeholder))
    }
}
