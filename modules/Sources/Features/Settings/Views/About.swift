//
//  About.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.03.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated

public struct About: View {
    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text(L10n.Settings.version(viewStore.appVersion, viewStore.appBuild))
                    .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                
                Spacer()
            }
            .applyScreenBackground()
        }
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About(store: .placeholder)
    }
}
