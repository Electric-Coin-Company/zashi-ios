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
    @Perception.Bindable var store: StoreOf<RestoreInfo>
    
    public init(store: StoreOf<RestoreInfo>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                Text(L10n.RestoreInfo.title)
                    .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                    .padding(.vertical, 30)
                
                Asset.Assets.restoreInfo.image
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 106, height: 168)
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    Text(L10n.RestoreInfo.tips)
                        .font(.custom(FontFamily.Inter.bold.name, size: 14))
                    
                    bulletpoint(L10n.RestoreInfo.tip1)
                    bulletpoint(L10n.RestoreInfo.tip2)
                    bulletpoint(L10n.RestoreInfo.tip3)

                    Text(L10n.RestoreInfo.note)
                        .font(.custom(FontFamily.Inter.medium.name, size: 11))
                        .padding(.top, 20)
                }
                .padding(.horizontal, 30)
                
                Button(L10n.RestoreInfo.gotIt.uppercased()) {
                    store.send(.gotItTapped)
                }
                .zcashStyle()
                .padding(.vertical, 50)
                .padding(.horizontal, 40)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 1)
            .zashiBack(hidden: true)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
    }
    
    @ViewBuilder
    private func bulletpoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Circle()
                .frame(width: 4, height: 4)
                .padding(.top, 7)
                .padding(.leading, 8)

            Text(text)
                .font(.custom(FontFamily.Inter.regular.name, size: 14))
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
