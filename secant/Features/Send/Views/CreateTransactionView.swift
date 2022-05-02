import SwiftUI
import ComposableArchitecture

struct CreateTransaction: View {
    @Binding var transaction: Transaction
    @Binding var isComplete: Bool

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return VStack {
            VStack {
                Text("ZEC Amount")

                TextField(
                    "ZEC Amount",
                    text: $transaction.amountString
                )
                .padding()
                .background(Color.white)
                .foregroundColor(Asset.Colors.Text.importSeedEditor.color)
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

// MARK: - Previews

struct Create_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(
                initialState: (
                    Transaction.placeholder,
                    false
                )
            ) {
                CreateTransaction(
                    transaction: $0.0,
                    isComplete: $0.1
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
                transaction: .placeholder
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
