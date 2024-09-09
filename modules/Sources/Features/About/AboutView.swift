//
//  AboutView.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-13-2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import WhatsNew

public struct AboutView: View {
    @Environment(\.openURL) var openURL
    
    @Perception.Bindable var store: StoreOf<About>
    
    public init(store: StoreOf<About>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    Asset.Assets.zashiTitle.image
                        .zImage(width: 63, height: 17, color: Asset.Colors.primary.color)
                        .padding(.top, 15)
                        .padding(.bottom, 8)
                    
                    Text(L10n.About.version(store.appVersion, store.appBuild))
                        .font(.custom(FontFamily.Inter.bold.name, size: 12))
                        .foregroundColor(Asset.Colors.primary.color)
                        .padding(.bottom, 25)
                }
                .frame(maxWidth: .infinity)

                Text(L10n.About.info)
                    .font(.custom(FontFamily.Inter.regular.name, size: 14))
                    .foregroundColor(Asset.Colors.shade30.color)
                    .padding(.bottom, 30)

                Button(L10n.About.whatsNew.uppercased()) {
                    store.send(.whatsNewButtonTapped)
                }
                .zcashStyle(
                    minWidth: nil,
                    fontSize: 10,
                    height: 38,
                    shadowOffset: 6
                )
                .padding(.bottom, 15)

                Button(L10n.About.privacyPolicy.uppercased()) {
                    if let url = URL(string: "https://electriccoin.co/zashi-privacy-policy/") {
                        openURL(url)
                    }
                }
                .zcashStyle(
                    minWidth: nil,
                    fontSize: 10,
                    height: 38,
                    shadowOffset: 6
                )
                .padding(.bottom, 25)

                Spacer()
            }
            .padding(.top, 20)
            .onAppear { store.send(.onAppear) }
            .zashiBack()
            .screenTitle(L10n.Settings.about)
            .padding(.horizontal, 70)
            .walletStatusPanel(background: .transparent)
            .navigationLinkEmpty(
                isActive: $store.whatsNewViewBinding,
                destination: {
                    WhatsNewView(
                        store: store.scope(
                            state: \.whatsNewState,
                            action: \.whatsNew
                        )
                    )
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}

// MARK: Placeholders

extension About.State {
    public static let initial = About.State(whatsNewState: .initial)
}

extension About {
    public static let initial = StoreOf<About>(
        initialState: .initial
    ) {
        About()
    }
}

#Preview {
    NavigationView {
        AboutView(store: About.initial)
    }
}
