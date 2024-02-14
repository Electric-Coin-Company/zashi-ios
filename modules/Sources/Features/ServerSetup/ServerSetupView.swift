//
//  ServerSetupView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-02-07.
//

import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents
import ZcashSDKEnvironment

public struct ServerSetupView: View {
    @Perception.Bindable var store: StoreOf<ServerSetup>
    
    public init(store: StoreOf<ServerSetup>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .center) {
                Text(L10n.ServerSetup.title)
                    .font(.custom(FontFamily.Inter.medium.name, size: 16))
                    .foregroundColor(Asset.Colors.primary.color)
                    .padding(.vertical, 25)
                
                ForEach(ZcashSDKEnvironment.Servers.allCases, id: \.self) { server in
                    HStack(spacing: 0) {
                        Button {
                            store.send(.someServerTapped(server))
                        } label: {
                            HStack(spacing: 10) {
                                if server == store.server {
                                    Circle()
                                        .fill(Asset.Colors.primary.color)
                                        .frame(width: 20, height: 20)
                                        .overlay {
                                            Circle()
                                                .fill(Asset.Colors.secondary.color)
                                                .frame(width: 8, height: 8)
                                        }
                                } else {
                                    Circle()
                                        .stroke(Asset.Colors.primary.color)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(server.server()).tag(server)
                                    .font(.custom(FontFamily.Inter.medium.name, size: 14))
                                    .foregroundColor(Asset.Colors.shade30.color)
                            }
                        }
                        .padding(.vertical, 6)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                if store.server == .custom {
                    TextField(L10n.ServerSetup.placeholder, text: $store.customServer)
                        .frame(height: 40)
                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        .foregroundColor(Asset.Colors.shade30.color)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 10)
                        .overlay {
                            Rectangle()
                                .stroke(Asset.Colors.primary.color, lineWidth: 1)
                        }
                        .padding(.top, 8)
                }
                
                Button {
                    store.send(.setServerTapped)
                } label: {
                    if store.isUpdatingServer {
                        HStack(spacing: 8) {
                            Text(L10n.General.save.uppercased())
                            ProgressView()
                        }
                    } else {
                        Text(L10n.General.save.uppercased())
                    }
                }
                .zcashStyle()
                .padding(.top, 35)
                .padding(.horizontal, 70)
                .disabled(store.isUpdatingServer)
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .zashiBack(store.isUpdatingServer)
            .zashiTitle {
                Asset.Assets.zashiTitle.image
                    .resizable()
                    .frame(width: 62, height: 17)
            }
            .onAppear { store.send(.onAppear) }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Previews

#Preview {
    ServerSetupView(
        store: .init(
            initialState:
                ServerSetup.State(server: .custom)
        ) {
            ServerSetup()
        }
    )
}

// MARK: Placeholders

extension ServerSetup.State {
    public static let initial = ServerSetup.State()
}

extension ServerSetup {
    public static let placeholder = StoreOf<ServerSetup>(
        initialState: .initial
    ) {
        ServerSetup()
    }
}
