import SwiftUI

#if DEBUG
struct StateContainer<T, Content: View>: View {
    @State private var state: T
    private var content: (Binding<T>) -> Content

    init(initialState: T, content: @escaping (Binding<T>) -> Content) {
        self._state = State(initialValue: initialState)
        self.content = content
    }

    var body: some View {
        content($state)
    }
}
#endif
