import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models
import ZcashLightClientKit
import TransactionDetails
import AddressBook

public struct TransactionListView: View {
    let store: StoreOf<TransactionList>
    let tokenName: String
    
    public init(store: StoreOf<TransactionList>, tokenName: String) {
        self.store = store
        self.tokenName = tokenName
    }
    
    public var body: some View {
        WithPerceptionTracking {
            List {
                if store.isInvalidated {
                    VStack {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                    .padding(.top, 30)
                } else {
                    ForEach(store.transactionListHomePage) { transaction in
                        WithPerceptionTracking {
                            Button {
                                store.send(.transactionTapped(transaction.id))
                            } label: {
                                TransactionRowView(
                                    store: store,
                                    transaction: transaction,
                                    isLatestTransaction: store.latestTransactionId == transaction.id
                                )
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .listRowBackground(Asset.Colors.background.color)
                    .listRowSeparator(.hidden)
                }
            }
            .navigationLinkEmpty(
                isActive: store.bindingForStack(.transactionDetails),
                destination: {
                    TransactionDetailsView(store: store.transactionDetailsStore(), tokenName: tokenName)
                        .navigationLinkEmpty(
                            isActive: store.bindingForStack(.addressBookNewContact),
                            destination: {
                                AddressBookContactView(store: store.addressBookStore())
                            }
                        )
                }
            )
            .disabled(store.transactionList.isEmpty)
            .applyScreenBackground()
            .listStyle(.plain)
            .onAppear { store.send(.onAppear) }
            .onDisappear(perform: { store.send(.onDisappear) })
        }
    }
}

// MARK: - Store

extension StoreOf<TransactionList> {
    func transactionDetailsStore() -> StoreOf<TransactionDetails> {
        self.scope(
            state: \.transactionDetailsState,
            action: \.transactionDetails
        )
    }
    
    func addressBookStore() -> StoreOf<AddressBook> {
        self.scope(
            state: \.addressBookState,
            action: \.addressBook
        )
    }
}

// MARK: - ViewStore

extension StoreOf<TransactionList> {
    func bindingForStack(_ destination: TransactionList.State.StackDestination) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                if let currentStackValue = self.stackDestination?.rawValue {
                    return currentStackValue >= destination.rawValue
                } else {
                    if destination.rawValue == 0 {
                        return false
                    } else if destination.rawValue <= self.stackDestinationBindingsAlive {
                        return true
                    } else {
                        return false
                    }
                }
            },
            set: { _ in
                if let currentStackValue = self.stackDestination?.rawValue, currentStackValue == destination.rawValue {
                    let popIndex = destination.rawValue - 1
                    if popIndex >= 0 {
                        let popDestination = TransactionList.State.StackDestination(rawValue: popIndex)
                        self.send(.updateStackDestination(popDestination))
                    } else {
                        self.send(.updateStackDestination(nil))
                    }
                }
            }
        )
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        TransactionListView(store: .placeholder, tokenName: "ZEC")
            .preferredColorScheme(.light)
    }
}

// MARK: Placeholders

extension TransactionList.State {
    public static var placeholder: Self {
        .init(transactionList: .mocked)
    }

    public static var initial: Self {
        .init(transactionList: [])
    }
}

extension StoreOf<TransactionList> {
    public static var placeholder: Store<TransactionList.State, TransactionList.Action> {
        Store(
            initialState: .placeholder
        ) {
            TransactionList()
                .dependency(\.zcashSDKEnvironment, .testnet)
        }
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    public static var placeholder: IdentifiedArrayOf<TransactionState> {
        .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    fee: Zatoshi(10),
                    id: String($0),
                    status: .paid,
                    timestamp: 1234567,
                    zecAmount: Zatoshi(25)
                )
            }
        )
    }
    
    public static var mocked: IdentifiedArrayOf<TransactionState> {
        .init(
            uniqueElements: [
                TransactionState.mockedSent,
                TransactionState.mockedReceived
            ]
        )
    }
}
