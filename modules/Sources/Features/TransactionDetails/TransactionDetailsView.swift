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

struct CustomRoundedRectangle: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public struct TransactionDetailsView: View {
    enum RowAppereance {
        case bottom
        case full
        case middle
        case top
        
        var corners: UIRectCorner {
            switch self {
            case .bottom:
                return [.bottomLeft, .bottomRight]
            case .full:
                return [.allCorners]
            case .middle:
                return []
            case .top:
                return [.topLeft, .topRight]
            }
        }
    }
    
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
                    .screenHorizontalPadding()

                ScrollView {
                    transactionDetailsList()
                        .padding(.bottom, 20)
                        .screenHorizontalPadding()
                    
                    messageView()
                        .screenHorizontalPadding()
                }
                
                Spacer()
                
                HStack(spacing: 12) {
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
                .screenHorizontalPadding()
            }
            .zashiBack()
            .navigationBarItems(trailing: bookmarkButton())
            .onAppear {
                store.send(.onAppear)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}

extension TransactionDetailsView {
    @ViewBuilder func bookmarkButton() -> some View {
        Button {
            store.send(.bookmarkTapped)
        } label: {
            Asset.Assets.Icons.bookmark.image
                .zImage(size: 32, style: Design.Text.primary)
                .padding(4)
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
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                    .frame(width: 51, height: 51)

                                Asset.Assets.Icons.shieldTickFilled.image
                                    .zImage(size: 24, style: Design.Text.light)
                            }
                        }
                        .offset(x: -4)
                }
                
                RoundedRectangle(cornerRadius: 24)
                    .fill(Design.Surfaces.bgTertiary.color(colorScheme))
                    .frame(width: 48, height: 48)
                    .overlay {
                        ZStack {
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Design.Surfaces.bgPrimary.color(colorScheme), style: StrokeStyle(lineWidth: 3.0))
                                .frame(width: 51, height: 51)
                            
                            transationIcon()
                                .zImage(size: 24, style: Design.Text.primary)
                        }
                    }
                    .offset(x: store.transaction.isShieldingTransaction ? -8 : -4)
            }
            .offset(x: store.transaction.isShieldingTransaction ? 4 : 2)
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
    
    @ViewBuilder func transactionDetailsList() -> some View {
        WithPerceptionTracking {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("Transaction Details")
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)
                
                Button {
                    store.send(.sentToRowTapped, animation: .easeInOut)
                } label: {
                    detailView(
                        title: "Send to",
                        value: "Lukas",
                        icon: store.areDetailsExpanded
                        ? Asset.Assets.chevronUp.image
                        : Asset.Assets.chevronDown.image,
                        rowAppereance: store.areDetailsExpanded ? .top : .full
                    )
                }
                
                if store.areDetailsExpanded {
                    detailView(
                        title: "Fee",
                        value: "0.0001 ZEC",
                        rowAppereance: .middle
                    )
                    
                    detailView(
                        title: L10n.TransactionList.transactionId,
                        value: store.transaction.id.truncateMiddle,
                        rowAppereance: .middle
                    )
                    
                    if let date = store.transaction.dateString {
                        detailView(
                            title: "Completed",
                            value: date,
                            rowAppereance: .bottom
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder func detailView(
        title: String,
        value: String,
        icon: Image? = nil,
        rowAppereance: RowAppereance = .full
    ) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .zFont(size: 14, style: Design.Text.tertiary)
            
            Spacer()
            
            Text(value)
                .zFont(.medium, size: 14, style: Design.Text.primary)
                .lineLimit(1)
                
            if let icon {
                icon
                    .zImage(size: 20, style: Design.Text.primary)
                    .padding(.leading, 6)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background {
            CustomRoundedRectangle(corners: rowAppereance.corners, radius: 12)
                .fill(Design.Surfaces.bgSecondary.color(colorScheme))
        }
        .padding(.bottom, rowAppereance == .full || rowAppereance == .bottom ? 0 : 1)
    }
    
    @ViewBuilder func messageView() -> some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.Send.message)
                    .zFont(.medium, size: 14, style: Design.Text.tertiary)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    if store.isMessageExpanded {
                        Text("Hey man, just sent over the $250 I owe you for the football tickets. Thanks again for covering me at the game, really appreciate it! Sorry it took me a bit to get this to you, things have been a bit hectic. I’m hoping we can hit another game soon—maybe next time I’ll grab the tickets and we can make it a whole weekend thing! Let me know if you get the payment alright, but it should come through no problem. Hope all’s good with you, let’s catch up soon and plan something! Thanks again, and talk to you later!")
                            .zFont(size: 14, style: Design.Text.primary)
                    } else {
                        Text("Hey man, just sent over the $250 I owe you for the football tickets. Thanks again for covering me at the game, really appreciate it...")
                            .zFont(size: 14, style: Design.Text.primary)
                    }
                    
                    Button {
                        store.send(.messageTapped, animation: .easeInOut)
                    } label: {
                        HStack(spacing: 6) {
                            Text(store.isMessageExpanded
                                 ? "View less"
                                 : "View more"
                            )
                            .zFont(.medium, size: 14, style: Design.Text.primary)
                            
                            
                            if store.isMessageExpanded {
                                Asset.Assets.chevronUp.image
                                    .zImage(size: 16, style: Design.Text.primary)
                            } else {
                                Asset.Assets.chevronDown.image
                                    .zImage(size: 16, style: Design.Text.primary)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Design.Surfaces.bgSecondary.color(colorScheme))
                }
            }
            .frame(maxWidth: .infinity)
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
