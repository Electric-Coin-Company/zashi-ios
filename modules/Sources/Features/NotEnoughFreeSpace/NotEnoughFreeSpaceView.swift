//
//  NotEnoughFreeSpaceView.swift
//  secant-testnet
//
//  Created by Michal Fousek on 28.09.2022.
//

import SwiftUI
import ComposableArchitecture

import Generated
import Settings
import UIComponents

public struct NotEnoughFreeSpaceView: View {
    @Perception.Bindable var store: StoreOf<NotEnoughFreeSpace>
    
    public init(store: StoreOf<NotEnoughFreeSpace>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack {
                ZashiErrorIcon()
                    .padding(.vertical, 20)
                
                Text(L10n.NotEnoughFreeSpace.message1(store.freeSpaceRequiredForSync, store.freeSpace))
                    .font(.custom(FontFamily.Inter.bold.name, size: 22))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                Text(L10n.NotEnoughFreeSpace.message2)
                    .font(.custom(FontFamily.Inter.regular.name, size: 17))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 53)
            .padding(.vertical, 1)
            .onAppear { store.send(.onAppear) }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: settingsButton())
            .applyScreenBackground()
            .zashiTitle {
                Text(L10n.NotEnoughFreeSpace.title.uppercased())
                    .font(.custom(FontFamily.Archivo.bold.name, size: 14))
            }
        }
    }
    
    func settingsButton() -> some View {
        return Image(systemName: "line.3.horizontal")
            .resizable()
            .frame(width: 21, height: 15)
            .padding(15)
            .navigationLink(
                isActive: $store.isSettingsOpen,
                destination: {
                    SettingsView(
                        store:
                            store.scope(
                                state: \.settingsState,
                                action: \.settings
                            )
                    )
                }
            )
            .tint(Asset.Colors.primary.color)
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        NotEnoughFreeSpaceView(
            store:
                StoreOf<NotEnoughFreeSpace>(
                    initialState: NotEnoughFreeSpace.State(
                        settingsState: .initial
                    )
                ) {
                    NotEnoughFreeSpace()
                }
        )
    }
}

// MARK: Placeholders

extension NotEnoughFreeSpace.State {
    public static let initial = NotEnoughFreeSpace.State(
        settingsState: .initial
    )
}

extension NotEnoughFreeSpace {
    public static let placeholder = StoreOf<NotEnoughFreeSpace>(
        initialState: .initial
    ) {
        NotEnoughFreeSpace()
    }
}
