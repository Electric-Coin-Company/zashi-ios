import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import Utils

struct TransactionDetailView: View {
    enum RowMark {
        case neutral
        case success
        case fail
        case inactive
        case highlight
    }

    var transaction: TransactionState
    var store: WalletEventsFlowStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                header

                HStack {
                    VStack(alignment: .leading) {
                        switch transaction.status {
                        case .paid:
                            Text(L10n.Transaction.youSent(transaction.zecAmount.decimalString(), TargetConstants.tokenName))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)
                            
                        case .sending:
                            Text(L10n.Transaction.youAreSending(transaction.zecAmount.decimalString(), TargetConstants.tokenName))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)

                        case .receiving:
                            Text(L10n.Transaction.youAreReceiving(transaction.zecAmount.decimalString(), TargetConstants.tokenName))
                                .padding()
                            memo(transaction, viewStore, mark: .highlight)

                        case .received:
                            Text(L10n.Transaction.youReceived(transaction.zecAmount.decimalString(), TargetConstants.tokenName))
                                .padding()
                            memo(transaction, viewStore, mark: .highlight)
                            
                        case .failed:
                            Text(L10n.Transaction.youDidNotSent(transaction.zecAmount.decimalString(), TargetConstants.tokenName))
                                .padding()

                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)

                            Text(L10n.TransactionDetail.error(transaction.errorMessage ?? L10n.General.unknown))
                                .padding()
                        }
                    }
                    
                    Spacer()
                }

                Spacer()
            }
            .applyScreenBackground()
            .navigationTitle(L10n.TransactionDetail.title)
        }
    }
}

extension TransactionDetailView {
    var header: some View {
        HStack {
            switch transaction.status {
            case .sending:
                Text(L10n.Transaction.sending)
                Spacer()
            case .receiving:
                Text(L10n.Transaction.receiving)
                Spacer()
            case .failed:
                Text("\(transaction.date?.asHumanReadable() ?? L10n.General.dateNotAvailable)")
            default:
                Text("\(transaction.date?.asHumanReadable() ?? L10n.General.dateNotAvailable)")
            }
        }
        .padding()
    }
    
    func address(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        Text("\(addressPrefixText) \(transaction.address)")
            .lineLimit(1)
            .truncationMode(.middle)
            .padding()
    }
    
    func memo(
        _ transaction: TransactionState,
        _ viewStore: WalletEventsFlowViewStore,
        mark: RowMark = .neutral
    ) -> some View {
        Group {
            if let memoText = transaction.memos?.first?.toString() {
                VStack(alignment: .leading) {
                    Text(L10n.Transaction.withMemo)
                        .padding(.leading)
                    Text("\"\(memoText)\"")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                }
            } else {
                EmptyView()
            }
        }
    }
    
    func confirmed(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        HStack {
            Text(L10n.Transaction.confirmed)
            Spacer()
            Text(L10n.Transaction.confirmedTimes(transaction.confirmationsWith(viewStore.latestMinedHeight)))
        }
        .transactionDetailRow(mark: mark)
    }

    func confirming(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        HStack {
            Text(L10n.Transaction.confirming(viewStore.requiredTransactionConfirmations))
            Spacer()
            Text("\(transaction.confirmationsWith(viewStore.latestMinedHeight))/\(viewStore.requiredTransactionConfirmations)")
        }
        .transactionDetailRow(mark: mark)
    }
}

extension TransactionDetailView {
    var addressPrefixText: String {
        (transaction.status == .received || transaction.status == .receiving)
        ? "" : L10n.Transaction.to
    }
    
    var heightText: String {
        guard let minedHeight = transaction.minedHeight else { return L10n.Transaction.unconfirmed }
        return minedHeight > 0 ? String(minedHeight) : L10n.Transaction.unconfirmed
    }
}

// MARK: - Row modifier

struct TransactionDetailRow: ViewModifier {
    let mark: TransactionDetailView.RowMark
    let textColor: Color
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(backgroundColor)
            .padding(.leading, 20)
            .background(markColor(mark))
    }
    
    private func markColor(_ mark: TransactionDetailView.RowMark) -> Color {
        let markColor: Color
        
        switch mark {
        case .neutral: markColor = Asset.Colors.TransactionDetail.neutralMark.color
        case .success: markColor = Asset.Colors.TransactionDetail.succeededMark.color
        case .fail:  markColor = Asset.Colors.TransactionDetail.failedMark.color
        case .inactive:  markColor = Asset.Colors.TransactionDetail.inactiveMark.color
        case .highlight:  markColor = Asset.Colors.TransactionDetail.highlightMark.color
        }
        
        return markColor
    }
}

extension View {
    func transactionDetailRow(
        mark: TransactionDetailView.RowMark = .neutral
    ) -> some View {
        modifier(
            TransactionDetailRow(
                mark: mark,
                textColor: mark == .inactive ?
                Asset.Colors.TransactionDetail.inactiveMark.color :
                Asset.Colors.Text.transactionDetailText.color,
                backgroundColor: Asset.Colors.BackgroundColors.numberedChip.color
            )
        )
    }
}

// MARK: - Previews

struct TransactionDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionDetailView(
                transaction:
                    TransactionState(
                        errorMessage: L10n.Error.rollBack,
                        memos: [Memo.placeholder],
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .paid(success: true),
                        timestamp: 1234567,
                        zecAmount: Zatoshi(25_000_000)
                    ),
                store: WalletEventsFlowStore.placeholder
            )
            .preferredColorScheme(.light)
        }
        
        NavigationView {
            TransactionDetailView(
                transaction:
                    TransactionState(
                        errorMessage: L10n.Error.rollBack,
                        memos: [Memo.placeholder],
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .sending,
                        timestamp: 1234567,
                        zecAmount: Zatoshi(25_000_000)
                    ),
                store: WalletEventsFlowStore.placeholder
            )
            .preferredColorScheme(.light)
        }
        
        NavigationView {
            TransactionDetailView(
                transaction:
                    TransactionState(
                        errorMessage: L10n.Error.rollBack,
                        memos: [Memo.placeholder],
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .failed,
                        timestamp: 1234567,
                        zecAmount: Zatoshi(25_000_000)
                    ),
                store: WalletEventsFlowStore.placeholder
            )
            .preferredColorScheme(.light)
        }
        
        NavigationView {
            TransactionDetailView(
                transaction:
                    TransactionState(
                        errorMessage: L10n.Error.rollBack,
                        memos: [Memo.placeholder],
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .received,
                        timestamp: 1234567,
                        zecAmount: Zatoshi(25_000_000)
                    ),
                store: WalletEventsFlowStore.placeholder
            )
            .preferredColorScheme(.light)
        }
    }
}

private extension Memo {
    // swiftlint:disable:next force_try
    static let placeholder = try! Memo(string:
    """
    Testing some long memo so I can see many lines of text \
    instead of just one. This can take some time and I'm \
    bored to write all this stuff.
    """)
}
