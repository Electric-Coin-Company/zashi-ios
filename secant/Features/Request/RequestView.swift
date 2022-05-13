import SwiftUI
import ComposableArchitecture

struct RequestView: View {
    let store: RequestStore

    var body: some View {
        WithViewStore(store) { _ in
            Text("\(String(describing: Self.self)) PlaceHolder")
        }
    }
}

// MARK: - Previews

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView(store: .placeholder)
    }
}
