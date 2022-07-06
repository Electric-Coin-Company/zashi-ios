//
//  AddressDetailsView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture

struct AddressDetails: View {
    let store: AddressDetailsStore
    
    var body: some View {
        WithViewStore(store) { _ in
            Text("Address Details")
        }
    }
}

struct AddressDetails_Previews: PreviewProvider {
    static var previews: some View {
    AddressDetails(store: .placeholder)
    }
}
