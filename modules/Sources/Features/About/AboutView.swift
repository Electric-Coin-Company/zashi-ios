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

public struct AboutView: View {
    @Environment(\.openURL) var openURL
    
    @Perception.Bindable var store: StoreOf<About>
    
    public init(store: StoreOf<About>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.About.title)
                        .zFont(.semiBold, size: 24, style: Design.Text.primary)
                        .padding(.top, 40)
                    
                    Text(L10n.About.info)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 12)
                    
                    Text(L10n.About.additionalInfo)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 8)
                }

                ActionRow(
                    icon: Asset.Assets.infoCircle.image,
                    title: L10n.About.privacyPolicy,
                    divider: false,
                    horizontalPadding: 4
                ) {
                    if let url = URL(string: "https://electriccoin.co/zashi-privacy-policy/") {
                        openURL(url)
                    }
                }
                .padding(.top, 32)

                Spacer()
                
                Asset.Assets.zashiTitle.image
                    .zImage(width: 73, height: 20, color: Asset.Colors.primary.color)
                    .padding(.bottom, 16)
                
                Text(L10n.Settings.version(store.appVersion, store.appBuild))
                    .zFont(size: 16, style: Design.Text.tertiary)
                    .padding(.bottom, 24)
            }
            .onAppear { store.send(.onAppear) }
            .zashiBack()
            .screenTitle(L10n.Settings.about)
            //..walletstatusPanel(background: .transparent)
        }
        //.navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
    }
}

// MARK: Placeholders

extension About.State {
    public static let initial = About.State()
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
