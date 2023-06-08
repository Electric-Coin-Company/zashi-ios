import SwiftUI
import ComposableArchitecture
import Utils

struct WithStateBinding<T: Equatable, Content: View>: View {
    @State var localState: T
    @Binding private var externalBindng: T
    private var content: (Binding<T>) -> Content

    init(binding: Binding<T>, content: @escaping (Binding<T>) -> Content) {
        _externalBindng = binding
        _localState = State(initialValue: binding.wrappedValue)
        self.content = content
    }

    var body: some View {
        content($localState)
            .onChange(of: localState) { externalBindng = $0 }
    }
}

// MARK: - Previews

struct WithStateBinding_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // swiftlint:disable:next large_tuple
            StateContainer(initialState: (false, false, false)) { (binding: Binding<(Bool, Bool, Bool)>) in
                List {
                    NavigationLink(
                        isActive: binding.0,
                        destination: { Text("Standard State Binding") },
                        label: { Text("Standard State Binding") }
                    )

                    NavigationLink(
                        isActive: Binding(
                            get: { binding.1.wrappedValue },
                            set: { binding.1.wrappedValue = $0 }
                        ),
                        destination: { Text("Custom Binding") },
                        label: { Text("Custom Binding") }
                    )

                    WithStateBinding(
                        binding: Binding(
                            get: { binding.2.wrappedValue },
                            set: { binding.2.wrappedValue = $0 }
                        ),
                        content: {
                            NavigationLink(
                                isActive: $0,
                                destination: { Text("Wrapped Custom Binding") },
                                label: { Text("Wrapped Custom Binding") }
                            )
                        }
                    )
                }
            }
        }
    }
}
