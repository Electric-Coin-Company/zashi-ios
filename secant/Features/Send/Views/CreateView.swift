import SwiftUI
import ComposableArchitecture

struct Create: View {
    @Binding var transaction: Transaction
    @Binding var isComplete: Bool

    var body: some View {
        UITextView.appearance().backgroundColor = .clear
        
        return VStack {
            VStack {
                Text("Zatoshi Amount")

                TextField(
                    "Zatoshi Amount",
                    text: $transaction
                        .amount
                        .compactMap(
                            extract: String.init,
                            embed: UInt.init
                        )
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
                Create(
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
                transaction: .placeholder,
                route: nil
            ),
            reducer: .default,
            environment: SendEnvironment(
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }
}
#endif
