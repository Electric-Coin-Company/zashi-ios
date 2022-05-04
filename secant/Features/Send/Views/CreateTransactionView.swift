import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    let store: TransactionInputStore

    @Binding var transaction: Transaction
    @Binding var isComplete: Bool
    @Binding var totalBalance: Double

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return WithViewStore(store) { viewStore in
            VStack {
                VStack {
                    Text("Balance \(totalBalance)")
                    
                    SingleLineTextField(
                        placeholderText: "0",
                        title: "How much ZEC would you like to send?",
                        store: store.scope(
                            state: \.textFieldState,
                            action: TransactionInputAction.textField
                        ),
                        titleAccessoryView: {
                            Button(
                                action: { viewStore.send(.setMax(viewStore.maxValue)) },
                                label: { Text("Max") }
                            )
                                .textFieldTitleAccessoryButtonStyle
                        },
                        inputAccessoryView: {
                        }
                    )
                }
                .padding()
                
                VStack {
                    Text("To Address")
                    
                    TextField(
                        "Address",
                        text: $transaction.toAddress
                    )
                        .font(.system(size: 14))
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Asset.Colors.Text.importSeedEditor.color)
                }
                .padding()
                
                VStack {
                    Text("Memo")
                    
                    TextEditor(text: $transaction.memo)
                        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
                        .importSeedEditorModifier()
                }
                .padding()
                
                Button(
                    action: { isComplete = true },
                    label: { Text("Send") }
                )
                    .activeButtonStyle
                    .frame(height: 50)
                    .padding()
                
                Spacer()
            }
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
                initialState: (
                    Transaction.placeholder,
                    false,
                    0.0
                )
            ) {
                CreateTransaction(
                    store: .placeholder,
                    transaction: $0.0,
                    isComplete: $0.1,
                    totalBalance: $0.2
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

#if DEBUG
extension SendStore {
    static var placeholder: SendStore {
        return SendStore(
            initialState: .init(
                route: nil,
                transaction: .placeholder,
                transactionInputState: .placeholer
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
#endif
