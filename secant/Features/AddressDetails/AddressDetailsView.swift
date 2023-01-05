//
//  AddressDetailsView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import SwiftUI
import ComposableArchitecture

struct AddressDetailsView: View {
    let store: AddressDetailsStore
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Unified Address")
                
                Text("\(viewStore.unifiedAddress)")
                    .onTapGesture {
                        viewStore.send(.copyUnifiedAddressToPastboard)
                    }

                Text("Sapling Address")
                    .padding(.top, 20)

                Text("\(viewStore.saplingAddress)")
                    .onTapGesture {
                        viewStore.send(.copySaplingAddressToPastboard)
                    }

                Text("Transparent Address")
                    .padding(.top, 20)

                Text("\(viewStore.transparentAddress)")
                    .onTapGesture {
                        viewStore.send(.copyTransparentAddressToPastboard)
                    }
            }
            .padding(20)
            .applyScreenBackground()
        }
    }
}

struct AddressDetails_Previews: PreviewProvider {
    static var previews: some View {
    AddressDetailsView(store: .placeholder)
    }
}
