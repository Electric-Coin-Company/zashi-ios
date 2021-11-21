import SwiftUI
import ComposableArchitecture

struct Approve: View {
    enum Route: Equatable {
        case showSent(route: Sent.Route?)
    }

    let transaction: Transaction
    @Binding var route: Route?

    var body: some View {
        VStack {
            Button(
                action: { route = .showSent(route: nil) },
                label: { Text("Go to sent") }
            )
            .primaryButtonStyle
            .frame(height: 50)
            .padding()

            Text("\(String(dumping: transaction))")
            Text("\(String(dumping: route))")

            Spacer()
        }
        .navigationTitle(Text("2. Approve"))
        .navigationLinkEmpty(
            isActive: $route.map(
                extract: {
                    if case .showSent = $0 {
                        return true
                    } else {
                        return false
                    }
                },
                embed: { $0 ? .showSent(route: (/Route.showSent).extract(from: route)) : nil }
            ),
            destination: {
                Sent(
                    transaction: transaction,
                    route:  $route.map(
                        extract: /Route.showSent,
                        embed: Route.showSent
                    )
                )
            }
        )
    }
}

struct Approve_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StateContainer(initialState: (Transaction.demo, Approve.Route?.none)) {
                Approve(
                    transaction: $0.0.wrappedValue,
                    route: $0.1
                )
            }
        }
    }
}
