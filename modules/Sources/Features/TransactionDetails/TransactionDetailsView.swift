//
//  TransactionDetailsView.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-08-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit

public struct TransactionDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Perception.Bindable var store: StoreOf<TransactionDetails>
    let tokenName: String
    
    public init(store: StoreOf<TransactionDetails>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .center, spacing: 0) {
                    Group {
                        Text(store.transaction.zecAmount.decimalString())
                        + Text(" \(tokenName)")
                            .foregroundColor(Design.Text.quaternary.color(colorScheme))
                    }
                    .zFont(.semiBold, size: 40, style: Design.Text.primary)
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                }
                
                //Text("detail is here \(store.transaction.id)")
                
                Spacer()
                
                HStack {
                    ZashiButton(
                        "Add a note",
                        type: .tertiary
                    ) {
                        
                    }

                    ZashiButton(
                        "Save address"
                    ) {
                        
                    }
                }
                .padding(.bottom, 24)
            }
            .zashiBack()
            .navigationBarItems(trailing: bookmarkButton())
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
}

extension TransactionDetailsView {
    @ViewBuilder func bookmarkButton() -> some View {
        Button {
            store.send(.bookmarkTapped)
        } label: {
            Asset.Assets.Icons.menu.image
                .zImage(size: 24, style: Design.Text.primary)
                .padding(8)
                .tint(Asset.Colors.primary.color)
        }
    }
}

// MARK: - Previews

#Preview {
    TransactionDetailsView(store: TransactionDetails.initial, tokenName: "ZEC")
}

// MARK: - Store

extension TransactionDetails {
    public static var initial = StoreOf<TransactionDetails>(
        initialState: .initial
    ) {
        TransactionDetails()
    }
}

// MARK: - Placeholders

extension TransactionDetails.State {
    public static let initial = TransactionDetails.State(transaction: .placeholder())
}
