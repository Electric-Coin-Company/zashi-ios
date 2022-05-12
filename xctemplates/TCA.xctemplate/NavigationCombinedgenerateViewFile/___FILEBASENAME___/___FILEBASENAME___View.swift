//___FILEHEADER___

import SwiftUI
import ComposableArchitecture

struct ___VARIABLE_productName:identifier___: View {
    let store: ___VARIABLE_productName:identifier___Store
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Text("Hello, World!")
        }
    }
}

struct ___VARIABLE_productName:identifier____Previews: PreviewProvider {
    static var previews: some View {
    ___VARIABLE_productName:identifier___(store: .placeholder)
    }
}
