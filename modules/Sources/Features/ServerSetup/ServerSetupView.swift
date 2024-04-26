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
    private enum Constants {
        // Time it takes to initiate the animated scroll after the screen is presented
        static let delayBeforeScroll = 500_000_000
    }

    private enum InputID: Hashable {
        case selection
    }
    
    @Perception.Bindable var store: StoreOf<ServerSetup>
    
    public init(store: StoreOf<ServerSetup>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollViewReader { value in
                WithPerceptionTracking {
                    VStack(alignment: .center, spacing: 0) {
                        Asset.Colors.secondary.color
                            .frame(height: 1)
                        
                        ScrollView {
                            ForEach(ZcashSDKEnvironment.Servers.allCases, id: \.self) { server in
                                WithPerceptionTracking {
                                    VStack {
                                        HStack(spacing: 0) {
                                            Button {
                                                store.send(.someServerTapped(server))
                                            } label: {
                                                HStack(spacing: 10) {
                                                    WithPerceptionTracking {
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
                                        
                                        WithPerceptionTracking {
                                            if store.server == .custom && server == .custom {
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
                                        }
                                    }
                                    .padding(.horizontal, 35)
                                    .id(server == store.server ? InputID.selection : nil)
                                }
                            }
                            .padding(.vertical, 20)
                            .task { @MainActor in
                                try? await Task.sleep(nanoseconds: Constants.delayBeforeScroll)
                                withAnimation {
                                    value.scrollTo(InputID.selection, anchor: .center)
                                }
                            }
                        }
                        
                        Asset.Colors.shade30.color
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .opacity(0.15)
                        
                        WithPerceptionTracking {
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
                            .padding(.top, 20)
                            .padding(.bottom, 35)
                            .padding(.horizontal, 70)
                            .disabled(store.isUpdatingServer)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .zashiBack(store.isUpdatingServer)
                    .zashiTitle {
                        Text(L10n.ServerSetup.title.uppercased())
                            .font(.custom(FontFamily.Archivo.bold.name, size: 14))
                    }
                    .onAppear {
                        store.send(.onAppear)
                    }
                    .alert($store.scope(state: \.alert, action: \.alert))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview {
    ServerSetupView(
        store: ServerSetup.placeholder
    )
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
