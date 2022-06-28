import SwiftUI
import ComposableArchitecture

struct TransactionDetailView: View {
    var transaction: TransactionState
    var viewStore: WalletEventsFlowViewStore
    
    var body: some View {
        ScrollView {
            HStack {
                Text("\(transaction.date.asHumanReadable())")
                Spacer()
                Text("HEIGHT \(heightText)")
            }
            .padding()

            Text("\(amountPrefixText) \(transaction.zecAmount.decimalString()) ZEC")
                .transactionDetailRow()
            
            Text("fee \(transaction.fee.decimalString()) ZEC")
                .transactionDetailRow()

            Text("total amount \(transaction.totalAmount.decimalString()) ZEC")
                .transactionDetailRow()

            Button {
                viewStore.send(.copyToPastboard(transaction.address))
            } label: {
                Text("\(addressPrefixText) \(transaction.address)")
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .transactionDetailRow()
            }

            if let memo = transaction.memo {
                Button {
                    viewStore.send(.copyToPastboard(memo))
                } label: {
                    VStack {
                        Text("\(memo)")
                            .multilineTextAlignment(.leading)
                        
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
                    .transactionDetailRow()
                }
            }

            HStack {
                Text("Confirmed")
                Spacer()
                Text("\(transaction.confirmations) times")
            }
            .transactionDetailRow()

            Spacer()
            
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

            Button { } label: {
                // TODO: Warn users that they will leave the App when they follow a Block explorer
                // https://github.com/zcash/secant-ios-wallet/issues/379
                if let viewOnlineURL = transaction.viewOnlineURL {
                    Link("View online", destination: viewOnlineURL)
                }
            }
            .activeButtonStyle
            .frame(height: 50)
            .padding(.horizontal, 30)
        }
        .applyScreenBackground()
        .navigationTitle("Transaction detail")
    }
}

extension TransactionDetailView {
    var amountPrefixText: String {
        transaction.status == .received ? "You received" : "You sent"
    }

    var addressPrefixText: String {
        transaction.status == .received ? "from" : "to"
    }
    
    var heightText: String {
        transaction.minedHeight > 0 ? String(transaction.minedHeight) : "unconfirmed"
    }
}

struct TransactionDetailRow: ViewModifier {
    let tint: Color
    let textColor: Color
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(backgroundColor)
            .padding(.leading, 20)
            .background(tint)
    }
}

extension View {
    func transactionDetailRow(
        _ tint: Color = Asset.Colors.BackgroundColors.red.color,
        _ textColor: Color = Asset.Colors.Text.transactionDetailText.color,
        _ backgroundColor: Color = Asset.Colors.BackgroundColors.numberedChip.color
    ) -> some View {
        modifier(
            TransactionDetailRow(
                tint: tint,
                textColor: textColor,
                backgroundColor: backgroundColor
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
                        memo:
                        """
                        Testing some long memo so I can see many lines of text \
                        instead of just one. This can take some time and I'm \
                        bored to write all this stuff.
                        """,
                        minedHeight: 1_875_256,
                        zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
                        fee: Zatoshi(amount: 1_000_000),
                        id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
                        status: .paid(success: true),
                        subtitle: "",
                        timestamp: 1234567,
                        zecAmount: Zatoshi(amount: 25_000_000)
                    ),
                viewStore: ViewStore(
                    WalletEventsFlowStore(
                        initialState: .placeHolder,
                        reducer: .default,
                        environment:
                            WalletEventsFlowEnvironment(
                                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                                SDKSynchronizer: MockWrappedSDKSynchronizer(),
                                pasteboard: .test
                            )
                    )
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
