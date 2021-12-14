import SwiftUI
import ComposableArchitecture

struct Approve: View {
    let transaction: Transaction
    @Binding var isComplete: Bool

    var body: some View {
        VStack {
            Button(
                action: { isComplete = true },
                label: { Text("Go to sent") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            Text("\(String(dumping: transaction))")
            Text("\(String(dumping: isComplete))")

            Spacer()
        }
        .navigationTitle(Text("2. Approve"))
    }
}

struct Approve_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(initialState: (Transaction.placeholder, false)) {
                Approve(
                    transaction: $0.0.wrappedValue,
                    isComplete: $0.1
                )
            }
        }
    }
}
