//
//  ServerSetupView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 2024-02-07.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UIComponents
import ZcashSDKEnvironment

public struct ServerSetupView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var customDismiss: (() -> Void)? = nil
    
    @Perception.Bindable var store: StoreOf<ServerSetup>
    
    public init(store: StoreOf<ServerSetup>, customDismiss: (() -> Void)? = nil) {
        self.store = store
        self.customDismiss = customDismiss
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollViewReader { value in
                WithPerceptionTracking {
                    VStack(alignment: .center, spacing: 0) {
                        ScrollView {
                            if store.topKServers.isEmpty {
                                VStack(spacing: 15) {
                                    progressView()
                                    
                                    Text(L10n.ServerSetup.performingTest)
                                        .font(.custom(FontFamily.Inter.semiBold.name, size: 20))
                                        .foregroundColor(Asset.Colors.primary.color)

                                    Text(L10n.ServerSetup.couldTakeTime)
                                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                        .foregroundColor(Asset.Colors.ServerSwitch.subtitle.color)
                                }
                                .frame(height: 136)
                            } else {
                                HStack {
                                    Text(L10n.ServerSetup.fastestServers)
                                        .font(.custom(FontFamily.Inter.semiBold.name, size: 18))
                                        .foregroundColor(Asset.Colors.primary.color)

                                    Spacer()
                                    
                                    Button {
                                        store.send(.refreshServersTapped)
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(L10n.ServerSetup.refresh)
                                                .font(.custom(FontFamily.Inter.semiBold.name, size: 14))
                                                .foregroundColor(Asset.Colors.primary.color)

                                            if store.isEvaluatingServers {
                                                progressView()
                                                    .scaleEffect(0.7)
                                            } else {
                                                Asset.Assets.refreshCCW2.image
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Asset.Colors.primary.color)
                                            }
                                        }
                                        .padding(5)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 20)

                                listOfServers(store.topKServers)
                            }

                            HStack {
                                Text(
                                    store.topKServers.isEmpty
                                    ? L10n.ServerSetup.allServers
                                    : L10n.ServerSetup.otherServers
                                )
                                .font(.custom(FontFamily.Inter.semiBold.name, size: 18))
                                .foregroundColor(Asset.Colors.primary.color)

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, store.topKServers.isEmpty ? 0 : 15)

                            listOfServers(store.servers)
                        }
                        .padding(.vertical, 1)

                        WithPerceptionTracking {
                            ZStack {
                                Asset.Colors.background.color
                                    .frame(height: 72)
                                    .cornerRadius(32)
                                    .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: -8)
                                
                                Button {
                                    store.send(.setServerTapped)
                                } label: {
                                    if store.isUpdatingServer {
                                        HStack(spacing: 8) {
                                            Text(L10n.ServerSetup.save)
                                                .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                                .foregroundColor(
                                                    store.selectedServer == nil
                                                    ? Asset.Colors.ServerSwitch.saveButtonDisabledText.color
                                                    : Asset.Colors.ServerSwitch.saveButtonActiveText.color
                                                )

                                            progressView(invertTint: true)
                                        }
                                        .frame(height: 48)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            store.selectedServer == nil
                                            ? Asset.Colors.ServerSwitch.saveButtonDisabled.color
                                            : Asset.Colors.ServerSwitch.saveButtonActive.color
                                        )
                                        .cornerRadius(10)
                                        .padding(.horizontal, 24)
                                    } else {
                                        Text(L10n.ServerSetup.save)
                                            .font(.custom(FontFamily.Inter.semiBold.name, size: 16))
                                            .frame(height: 48)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(
                                                store.selectedServer == nil
                                                ? Asset.Colors.ServerSwitch.saveButtonDisabledText.color
                                                : Asset.Colors.ServerSwitch.saveButtonActiveText.color
                                            )
                                            .background(
                                                store.selectedServer == nil
                                                ? Asset.Colors.ServerSwitch.saveButtonDisabled.color
                                                : Asset.Colors.ServerSwitch.saveButtonActive.color
                                            )
                                            .cornerRadius(10)
                                            .padding(.horizontal, 24)
                                    }
                                }
                                .disabled(store.isUpdatingServer)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .zashiBack(store.isUpdatingServer, customDismiss: customDismiss)
                    .zashiTitle {
                        Text(L10n.ServerSetup.title.uppercased())
                            .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                    }
                    .onAppear { store.send(.onAppear) }
                    .onDisappear { store.send(.onDisappear) }
                    .alert($store.scope(state: \.alert, action: \.alert))
                }
            }
            .applyScreenBackground()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func listOfServers(_ servers: [ZcashSDKEnvironment.Server]) -> some View {
        ForEach(servers, id: \.self) { server in
            WithPerceptionTracking {
                VStack {
                    HStack(spacing: 0) {
                        Button {
                            store.send(.someServerTapped(server))
                        } label: {
                            HStack(
                                alignment:
                                    isCustom(server) ? .top : .center,
                                spacing: 10
                            ) {
                                WithPerceptionTracking {
                                    if server.value(for: store.network) == store.activeServer && store.selectedServer == nil {
                                        Circle()
                                            .fill(Asset.Colors.primaryTint.color)
                                            .frame(width: 20, height: 20)
                                            .overlay {
                                                Asset.Assets.check.image
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(Asset.Colors.primary.color)
                                            }
                                    } else if server.value(for: store.network) == store.selectedServer {
                                        Circle()
                                            .fill(Asset.Colors.primary.color)
                                            .frame(width: 20, height: 20)
                                            .overlay {
                                                Asset.Assets.check.image
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(Asset.Colors.secondary.color)
                                            }
                                    } else {
                                        Circle()
                                            .stroke(Asset.Colors.ServerSwitch.checkOutline.color)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .padding(.top, isCustom(server) ? 16 : 0)

                                if isCustom(server) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(server.value(for: store.network))
                                                .font(.custom(FontFamily.Inter.medium.name, size: 14))
                                                .foregroundColor(Asset.Colors.primary.color)
                                                .multilineTextAlignment(.leading)

                                            Spacer()

                                            if server.value(for: store.network) == store.activeServer {
                                                activeBadge()
                                            }

                                            chevronDown()
                                        }
                                        
                                        WithPerceptionTracking {
                                            TextField(L10n.ServerSetup.placeholder, text: $store.customServer)
                                                .frame(height: 40)
                                                .font(.custom(FontFamily.Inter.medium.name, size: 14))
                                                .foregroundColor(Asset.Colors.shade30.color)
                                                .autocapitalization(.none)
                                                .multilineTextAlignment(.leading)
                                                .padding(.leading, 10)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Asset.Colors.ServerSwitch.fieldBcg.color)
                                                }
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Asset.Colors.ServerSwitch.fieldOutline.color, lineWidth: 1)
                                                }
                                                .padding(.vertical, 8)
                                        }
                                    }
                                    .padding(.vertical, 16)
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(
                                            isCustomButNotSelected(server) && !store.customServer.isEmpty
                                            ? store.customServer
                                            : server.value(for: store.network)
                                        )
                                        .font(.custom(FontFamily.Inter.medium.name, size: 14))
                                        .foregroundColor(Asset.Colors.primary.color)
                                        .multilineTextAlignment(.leading)
                                        
                                        if let desc = server.desc(for: store.network) {
                                            Text(desc)
                                                .font(.custom(FontFamily.Inter.regular.name, size: 14))
                                                .foregroundColor(Asset.Colors.ServerSwitch.desc.color)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if server.value(for: store.network) == store.activeServer && !isCustom(server) {
                                    activeBadge()
                                }
                                
                                if isCustomButNotSelected(server) {
                                    chevronDown()
                                }
                            }
                            .frame(minHeight: 48)
                            .padding(.leading, 24)
                            .padding(.trailing, isCustom(server) ? 0 : 24)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        server.value(for: store.network) == store.selectedServer
                                        ? Asset.Colors.ServerSwitch.highlight.color
                                        : Asset.Colors.background.color
                                    )
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 8)

                    if let last = servers.last, last != server {
                        Asset.Colors.ServerSwitch.divider.color
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    private func isCustom(_ server: ZcashSDKEnvironment.Server) -> Bool {
        store.selectedServer == L10n.ServerSetup.custom && server.value(for: store.network) == L10n.ServerSetup.custom
    }

    private func isCustomButNotSelected(_ server: ZcashSDKEnvironment.Server) -> Bool {
        store.selectedServer != L10n.ServerSetup.custom && server.value(for: store.network) == L10n.ServerSetup.custom
    }

    private func chevronDown() -> some View {
        Asset.Assets.chevronDown.image
            .renderingMode(.template)
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(Asset.Colors.primary.color)

    }

    private func activeBadge() -> some View {
        Text(L10n.ServerSetup.active)
            .font(.custom(FontFamily.Inter.medium.name, size: 14))
            .foregroundColor(Asset.Colors.ActiveBadge.text.color)
            .frame(height: 20)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(Asset.Colors.ActiveBadge.bcg.color)
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(Asset.Colors.ActiveBadge.outline.color, lineWidth: 1)
            }
    }
    
    private func progressView(invertTint: Bool = false) -> some View {
        ProgressView()
            .progressViewStyle(
                CircularProgressViewStyle(
                    tint: colorScheme == .dark 
                    ? (invertTint ? .black : .white) : (invertTint ? .white : .black)
                )
            )
    }
}

// MARK: - Previews

#Preview {
    NavigationView {
        ServerSetupView(
            store: ServerSetup.placeholder
        )
    }
}

// MARK: Placeholders

extension ServerSetup.State {
    public static var initial = ServerSetup.State()
}

extension ServerSetup {
    public static let placeholder = StoreOf<ServerSetup>(
        initialState: .initial
    ) {
        ServerSetup()
    }
}
