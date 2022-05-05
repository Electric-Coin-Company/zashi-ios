import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: SendStore

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 0) {
                    Text("Balance \(viewStore.totalBalance.asZecString()) ZEC")
                    Text("($\(viewStore.totalCurrencyBalance.asZecString()))")
                        .font(.system(size: 13))
                        .opacity(0.6)
                }
                .padding()

                VStack {
                    TransactionAmountTextField(
                        store: store.scope(
                            state: \.transactionAmountInputState,
                            action: SendAction.transactionAmountInput
                        )
                    )
                    
                    if viewStore.isInvalidAmountFormat {
                        HStack {
                            Text("invalid amount")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }

                    if viewStore.isInsufficientFunds {
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
                            action: SendAction.transactionAddressInput
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

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendStore {
    static var placeholder: SendStore {
        return SendStore(
            initialState: .init(
                route: nil,
                transaction: .placeholder,
                transactionAddressInputState: .placeholder,
                transactionAmountInputState: .placeholder
            ),
            reducer: .default,
            environment: SendEnvironment(
                mnemonicSeedPhraseProvider: .live,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                walletStorage: .live(),
                wrappedDerivationTool: .live(),
                wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }
}
// #endif
