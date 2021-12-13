import SwiftUI
import ComposableArchitecture

struct Sent: View {
    var transaction: Transaction
    @Binding var isComplete: Bool

    var body: some View {
        VStack {
            Button(
                action: {
                    isComplete = true
                },
                label: { Text("Done") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            Text("\(String(dumping: transaction))")
            Text("\(String(dumping: isComplete))")

            Spacer()
        }
        .navigationTitle(Text("3. Sent"))
    }
}

struct Done_Previews: PreviewProvider {
    static var previews: some View {
        Sent(transaction: .demo, isComplete: .constant(false))
    }
}
