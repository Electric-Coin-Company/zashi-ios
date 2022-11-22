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
            ScrollView {
                header

                switch transaction.status {
                case .paid(success: _):
                    plainText("You sent \(transaction.zecAmount.decimalString()) ZEC")
                    plainText("fee \(transaction.fee.decimalString()) ZEC", mark: .inactive)
                    plainText("total amount \(transaction.totalAmount.decimalString()) ZEC", mark: .inactive)
                    address(mark: .inactive, viewStore: viewStore)
                    if let text = transaction.memo?.toString() { memo(text, viewStore, mark: .highlight) }
                    confirmed(mark: .success, viewStore: viewStore)
                case .pending:
                    plainText("You are sending \(transaction.zecAmount.decimalString()) ZEC")
                    plainText("Includes network fee \(transaction.fee.decimalString()) ZEC", mark: .inactive)
                    plainText("total amount \(transaction.totalAmount.decimalString()) ZEC", mark: .inactive)
                    if let text = transaction.memo?.toString() { memo(text, viewStore, mark: .inactive) }
                    confirming(mark: .highlight, viewStore: viewStore)
                case .received:
                    plainText("You received \(transaction.zecAmount.decimalString()) ZEC")
                    plainText("fee \(transaction.fee.decimalString()) ZEC")
                    plainText("total amount \(transaction.totalAmount.decimalString()) ZEC")
                    address(mark: .inactive, viewStore: viewStore)
                    if let text = transaction.memo?.toString() { memo(text, viewStore, mark: .highlight) }
                    confirmed(mark: .success, viewStore: viewStore)
                case .failed:
                    plainText("You DID NOT send \(transaction.zecAmount.decimalString()) ZEC", mark: .fail)
                    plainText("Includes network fee \(transaction.fee.decimalString()) ZEC", mark: .inactive)
                    plainText("total amount \(transaction.totalAmount.decimalString()) ZEC", mark: .inactive)
                    if let text = transaction.memo?.toString() { memo(text, viewStore, mark: .inactive) }
                    if let errorMessage = transaction.errorMessage {
                        plainTwoColumnText(left: "Failed", right: errorMessage, mark: .fail)
                    }
                }

                Spacer()

                footer
            }
            .applyScreenBackground()
            .navigationTitle("Transaction detail")
        }
    }
}

extension TransactionDetailView {
    var header: some View {
        HStack {
            switch transaction.status {
            case .pending:
                Text("PENDING")
                Spacer()
            case .failed:
                Text("\(transaction.date.asHumanReadable())")
                Spacer()
                Text("FAILED")
            default:
                Text("\(transaction.date.asHumanReadable())")
                Spacer()
                Text("HEIGHT \(heightText)")
            }
        }
        .padding()
    }
    
    func plainText(_ text: String, mark: RowMark = .neutral) -> some View {
        Text(text)
            .transactionDetailRow(mark: mark)
    }

    func plainTwoColumnText(left: String, right: String, mark: RowMark = .neutral) -> some View {
        HStack {
            Text(left)
            Spacer()
            Text(right)
        }
        .transactionDetailRow(mark: mark)
    }

    func address(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        Button {
            viewStore.send(.copyToPastboard(transaction.address))
        } label: {
            Text("\(addressPrefixText) \(transaction.address)")
                .lineLimit(1)
                .truncationMode(.middle)
                .transactionDetailRow(mark: mark)
        }
    }
    
    func memo(
        _ memo: String,
        _ viewStore: WalletEventsFlowViewStore,
        mark: RowMark = .neutral
    ) -> some View {
        Button {
            viewStore.send(.copyToPastboard(memo))
        } label: {
            VStack {
                HStack {
                    Text("\(memo)")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("reply-to address included")
                    Spacer()
                    Button {
                        viewStore.send(.replyTo(transaction.address))
                    } label: {
                        Text("reply now")
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Asset.Colors.Text.transactionDetailText.color, lineWidth: 1)
                            )
                    }
                }
            }
            .transactionDetailRow(mark: mark)
        }
    }
    
    func confirmed(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        HStack {
            Text("Confirmed")
            Spacer()
            Text("\(transaction.confirmationsWith(viewStore.latestMinedHeight)) times")
        }
        .transactionDetailRow(mark: mark)
    }

    func confirming(mark: RowMark = .neutral, viewStore: WalletEventsFlowViewStore) -> some View {
        HStack {
            Text("Confirming ~\(viewStore.requiredTransactionConfirmations)mins")
            Spacer()
            Text("\(transaction.confirmationsWith(viewStore.latestMinedHeight))/\(viewStore.requiredTransactionConfirmations)")
        }
        .transactionDetailRow(mark: mark)
    }

    var footer: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Button {
                    viewStore.send(.copyToPastboard(transaction.id))
                } label: {
                    Text("txn: \(transaction.id)")
                        .foregroundColor(Asset.Colors.Text.transactionDetailText.color)
                        .font(.system(size: 14))
                        .fontWeight(.thin)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                        .background(Asset.Colors.BackgroundColors.numberedChip.color)
                        .padding(.vertical, 30)
                }

                Button("View online") {
                    viewStore.send(.warnBeforeLeavingApp(transaction.viewOnlineURL))
                }
                .activeButtonStyle
                .frame(height: 50)
                .padding(.horizontal, 30)
            }
            .alert(self.store.scope(state: \.alert), dismiss: .dismissAlert)
        }
    }
}

extension TransactionDetailView {
    var addressPrefixText: String {
        transaction.status == .received ? "from" : "to"
    }
    
    var heightText: String {
        transaction.minedHeight > 0 ? String(transaction.minedHeight) : "unconfirmed"
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
                        errorMessage: "possible roll back",
                        memo: try? Memo(string:
                        """
                        Testing some long memo so I can see many lines of text \
                        instead of just one. This can take some time and I'm \
                        bored to write all this stuff.
                        """),
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
            .preferredColorScheme(.dark)
        }
    }
}
