import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: SendFlowStore

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 0) {
                    Text("WalletBalance \(viewStore.shieldedBalance.total.decimalString()) ZEC")
                    Text("($\(viewStore.totalCurrencyBalance.decimalString()))")
                        .font(.system(size: 13))
                        .opacity(0.6)
                }
                .padding()

                VStack {
                    TransactionAmountTextField(
                        store: store.scope(
                            state: \.transactionAmountInputState,
                            action: SendFlowReducer.Action.transactionAmountInput
                        )
                    )
                    
                    if viewStore.isInvalidAmountFormat {
                        HStack {
                            Text("invalid amount")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    } else if viewStore.isInsufficientFunds {
                        HStack {
                            Text("insufficient funds")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }
                }
                .padding()

                VStack {
                    TransactionAddressTextField(
                        store: store.scope(
                            state: \.transactionAddressInputState,
                            action: SendFlowReducer.Action.transactionAddressInput
                        )
                    )
                    
                    if viewStore.isInvalidAddressFormat {
                        HStack {
                            Text("invalid address")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }
                }
                .padding()
                
                MultipleLineTextField(
                    store: store.memoStore(),
                    title: "Memo",
                    titleAccessoryView: {}
                )
                .frame(height: 200)
                .padding()
                
                Button(
                    action: { viewStore.send(.updateDestination(.confirmation)) },
                    label: { Text("Send") }
                )
                .activeButtonStyle
                .frame(height: 50)
                .padding()
                .disabled(!viewStore.isValidForm)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .applyScreenBackground()
        }
    }
}

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: ( false )
            ) { _ in
                CreateTransaction(store: .placeholder)
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}
