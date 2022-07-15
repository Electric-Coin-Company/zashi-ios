import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: SendFlowStore

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 0) {
                    Text("WalletBalance \(viewStore.totalBalance.decimalString()) ZEC")
                    Text("($\(viewStore.totalCurrencyBalance.decimalString()))")
                        .font(.system(size: 13))
                        .opacity(0.6)
                }
                .padding()

                VStack {
                    TransactionAmountTextField(
                        store: store.scope(
                            state: \.transactionAmountInputState,
                            action: SendFlowAction.transactionAmountInput
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
                            action: SendFlowAction.transactionAddressInput
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
                
                VStack {
                    Text("Memo")
                    
                    TextEditor(text: viewStore.bindingForMemo)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
                        .importSeedEditorModifier(Asset.Colors.Text.activeButtonText.color)
                }
                .padding()
                
                Button(
                    action: { viewStore.send(.updateRoute(.confirmation)) },
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
