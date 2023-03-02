import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

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
                            Text("transaction.youSent".localized("\(transaction.zecAmount.decimalString())"))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)
                            
                        case .pending:
                            Text("transaction.youAreSending".localized("\(transaction.zecAmount.decimalString())"))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)
                        case .received:
                            Text("transaction.youReceived".localized("\(transaction.zecAmount.decimalString())"))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)
                        case .failed:
                            Text("transaction.youDidNotSent".localized("\(transaction.zecAmount.decimalString())"))
                                .padding()
                            address(mark: .inactive, viewStore: viewStore)
                            memo(transaction, viewStore, mark: .highlight)
                        }
                    }
                    
                    Spacer()
                }

                Spacer()
            }
            .applyScreenBackground()
            .navigationTitle("transactionDetail.title")
        }
    }
}

extension TransactionDetailView {
    var header: some View {
        HStack {
            switch transaction.status {
            case .pending:
                Text("transaction.pending")
                Spacer()
            case .failed:
                Text("\(transaction.date?.asHumanReadable() ?? "general.dateNotAvailable")")
            default:
                Text("\(transaction.date?.asHumanReadable() ?? "general.dateNotAvailable")")
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
                    Text("transaction.withMemo")
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
            Text("transaction.confirmed")
            Spacer()
            Text("transaction.confirmedTimes".localized("\(transaction.confirmationsWith(viewStore.latestMinedHeight))"))
        }
        .transactionDetailRow(mark: mark)
    }

    func confirming(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        HStack {
            Text("transaction.confirming".localized("\(viewStore.requiredTransactionConfirmations)"))
            Spacer()
            Text("\(transaction.confirmationsWith(viewStore.latestMinedHeight))/\(viewStore.requiredTransactionConfirmations)")
        }
        .transactionDetailRow(mark: mark)
    }
}

extension TransactionDetailView {
    var addressPrefixText: String {
        transaction.status == .received ? "transaction.from" : "transaction.to"
    }
    
    var heightText: String {
        guard let minedHeight = transaction.minedHeight else { return "transaction.unconfirmed" }
        return minedHeight > 0 ? String(minedHeight) : "transaction.unconfirmed"
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
                        errorMessage: "error.rollBack",
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
                        errorMessage: "error.rollBack",
                        memos: [Memo.placeholder],
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .pending,
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
                        errorMessage: "error.rollBack",
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
                        errorMessage: "error.rollBack",
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
