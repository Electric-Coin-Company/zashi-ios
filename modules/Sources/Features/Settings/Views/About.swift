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
            VStack(alignment: .leading, spacing: 45) {
                HStack(spacing: 15) {
                    Asset.Assets.zashiLogo.image
                        .resizable()
                        .frame(width: 62, height: 81)
                    
                    Asset.Assets.zashiLogoText.image
                        .resizable()
                        .frame(width: 110, height: 30)
                }
                VStack(alignment: .leading, spacing: 25) {
                    Text(L10n.Settings.version(viewStore.appVersion, viewStore.appBuild))
                        .font(
                            .custom(FontFamily.Inter.bold.name, size: 14)
                            .weight(.bold)
                        )
                        .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                    Text(L10n.About.description)
                        .foregroundColor(Asset.Colors.Mfp.fontDark.color)
                        .font(
                            .custom(FontFamily.Inter.regular.name, size: 14)
                            .weight(.regular)
                        )
                }
                
                .padding(.leading, 12)
                .padding(.trailing, 60)
                Spacer()
            }
            .padding(.top, 50)
            .padding(.leading, 48)
            .navigationTitle(L10n.Settings.about.uppercased())
            .font(
                .custom(FontFamily.Inter.bold.name, size: 14)
                .weight(.bold)
            )
            .applyScreenBackground()
            .replaceNavigationBackButton()
        }
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About(store: .placeholder)
    }
}
