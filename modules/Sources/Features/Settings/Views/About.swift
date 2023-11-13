//
//  About.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.03.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct About: View {
    let store: SettingsStore
    
    public init(store: SettingsStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                HStack {
                    Asset.Assets.zashiLogo.image
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 62, height: 81)
                        .foregroundColor(Asset.Colors.primary.color)
                    
                    Asset.Assets.zashiTitle.image
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 109, height: 29)
                        .foregroundColor(Asset.Colors.primary.color)
                        .padding(.leading, 5)
                }
                .padding(.bottom, 48)
                .padding(.top, 30)
                
                Text(L10n.Settings.version(viewStore.appVersion, viewStore.appBuild))
                    .font(.custom(FontFamily.Inter.bold.name, size: 14))
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.bottom, 20)

                Text(L10n.Settings.About.info)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .foregroundColor(Asset.Colors.shade30.color)

                Spacer()
            }
            .applyScreenBackground()
            .zashiBack()
            .zashiTitle {
                Text(L10n.Settings.about.uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
            .padding(.horizontal, 70)
        }
    }
}

#Preview {
    NavigationView {
        About(store: .demo)
    }
}
