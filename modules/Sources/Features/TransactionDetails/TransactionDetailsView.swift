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
                headerView()

                Text("Transaction Details")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)

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

// Header
extension TransactionDetailsView {
    func transationIcon() -> Image {
        if store.transaction.isShieldingTransaction {
            return Asset.Assets.Icons.switchHorizontal.image
        } else if store.transaction.isSentTransaction {
            return Asset.Assets.Icons.sent.image
        } else {
            return Asset.Assets.Icons.received.image
        }
    }
    
    @ViewBuilder func headerView() -> some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Circle()
                    .frame(width: 48, height: 48)
                    .zForegroundColor(Design.Surfaces.brandBg)
                    .overlay {
                        ZcashSymbol()
                            .frame(width: 34, height: 34)
                            .foregroundColor(Asset.Colors.secondary.color)
                    }
                
                if store.transaction.isShieldingTransaction {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Design.Utility.Purple._500.color(colorScheme))
                        .frame(width: 48, height: 48)
                        .overlay {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                    .frame(width: 48, height: 48)

                                Asset.Assets.Icons.shieldTickFilled.image
                                    .zImage(size: 24, style: Design.Text.light)
                            }
                        }
                        .offset(x: -8)
                }
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                    .frame(width: 48, height: 48)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                .frame(width: 48, height: 48)
                            
                            transationIcon()
                                .zImage(size: 24, style: Design.Text.primary)
                        }
                    }
                    .offset(x: store.transaction.isShieldingTransaction ? -16 : -8)
            }
            .offset(x: store.transaction.isShieldingTransaction ? 8 : 4)
            .padding(.top, 24)
            
            Text(store.transaction.isShieldingTransaction
                 ? "Shielded"
                 : store.transaction.isSentTransaction
                 ? L10n.Transaction.sent
                 : L10n.Transaction.received
            )
            .zFont(.medium, size: 18, style: Design.Text.tertiary)
            .padding(.top, 10)

            Group {
                Text(store.transaction.zecAmount.decimalString())
                + Text(" \(tokenName)")
                    .foregroundColor(Design.Text.quaternary.color(colorScheme))
            }
            .zFont(.semiBold, size: 40, style: Design.Text.primary)
            .minimumScaleFactor(0.1)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
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
