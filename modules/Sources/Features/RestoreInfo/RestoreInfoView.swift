//
//  RestoreInfoView.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-03-2024
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct RestoreInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Perception.Bindable var store: StoreOf<RestoreInfo>
    
    public init(store: StoreOf<RestoreInfo>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Asset.Assets.Illustrations.connect.image
                    .resizable()
                    .frame(width: 132, height: 90)
                    .padding(.top, 40)
                    .padding(.bottom, 24)

                Text(L10n.RestoreInfo.title)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.bottom, 8)

                Text(L10n.RestoreInfo.subTitle)
                    .zFont(.medium, size: 16, style: Design.Text.primary)
                    .padding(.bottom, 16)

                Text(L10n.RestoreInfo.tips)
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.bottom, 4)

                bulletpoint(L10n.RestoreInfo.tip1)
                bulletpoint(L10n.RestoreInfo.tip2)
                    .padding(.bottom, 20)

                Spacer()

                Text("\(Text(L10n.RestoreInfo.note).bold())\(L10n.RestoreInfo.noteInfo)")
                    .zFont(size: 12, style: Design.Text.primary)
                    .padding(.bottom, 24)

                HStack {
                    ZashiToggle(
                        isOn: $store.isAcknowledged,
                        label: L10n.RestoreInfo.checkbox,
                        textSize: 16
                    )
                    
                    Spacer()
                }
                .padding(.leading, 1)
                
//                Group {
//                    Text(L10n.RestoreInfo.note)
//                        .font(.custom(FontFamily.Inter.bold.name, size: 12))
//                    + Text(L10n.RestoreInfo.noteInfo)
//                        .font(.custom(FontFamily.Inter.regular.name, size: 12))
//                }
//                .foregroundColor(Design.Text.primary.color(colorScheme))

                ZashiButton(L10n.RestoreInfo.gotIt) {
                    store.send(.gotItTapped)
                }
                .padding(.vertical, 24)
            }
            .zashiBack(hidden: true)
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyErredScreenBackground()
    }
    
    @ViewBuilder
    private func bulletpoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Circle()
                .frame(width: 4, height: 4)
                .padding(.top, 7)
                .padding(.leading, 8)

            Text(text)
                .zFont(size: 14, style: Design.Text.primary)
        }
        .padding(.bottom, 5)
    }
}

// MARK: - Previews

#Preview {
    RestoreInfoView(store: RestoreInfo.initial)
}

// MARK: - Store

extension RestoreInfo {
    public static var initial = StoreOf<RestoreInfo>(
        initialState: .initial
    ) {
        RestoreInfo()
    }
}

// MARK: - Placeholders

extension RestoreInfo.State {
    public static let initial = RestoreInfo.State()
}
