import SwiftUI
import ComposableArchitecture

struct ScanView: View {
    let store: ScanStore

    var body: some View {
        WithViewStore(store) { _ in
            Text("\(String(describing: Self.self)) PlaceHolder")
        }
    }
}

// MARK: - Previews

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(store: .placeholder)
    }
}
