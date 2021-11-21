import SwiftUI
import ComposableArchitecture

struct Sent: View {
    enum Route {
        case done
    }
    @State var transaction: Transaction
    @Binding var route: Route?

    var body: some View {
        VStack {
            Button(
                action: {
                    route = .done
                },
                label: { Text("Done") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()


            Text("\(String(dumping: transaction))")
            Text("\(String(dumping: route))")

            Spacer()
        }
        .navigationTitle(Text("3. Sent"))
    }
}

struct Done_Previews: PreviewProvider {
    static var previews: some View {
        Sent(transaction: .demo, route: .constant(nil))
    }
}
