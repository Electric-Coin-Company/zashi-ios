//
//  SyncProgressView.swift
//
//
//  Created by Lukáš Korba on 21.12.2023.
//

import SwiftUI
import ComposableArchitecture

import Generated
import UIComponents
import Models

public struct SyncProgressView: View {
    @Perception.Bindable var store: StoreOf<SyncProgress>
    
    public init(store: StoreOf<SyncProgress>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 5) {
                if store.isSyncing {
                    HStack {
                        Text(store.syncStatusMessage)
                            .font(.custom(FontFamily.Inter.regular.name, size: 10))
                            .foregroundColor(Asset.Colors.primary.color)
                        
                        // Frame height 0 is expected value because we want SwiftUI to ignore it
                        // for the vertical placement computation.
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 11, height: 0)
                    }
                } else {
                    if store.lastKnownErrorMessage != nil {
                        Button {
                            store.send(.errorMessageTapped)
                        } label: {
                            Text(store.syncStatusMessage)
                                .zFont(size: 10, style: Design.Text.primary)
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 35)
                        }
                    } else {
                        Text(store.syncStatusMessage)
                            .zFont(size: 10, style: Design.Text.primary)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 35)
                    }
                }
                
                Text(String(format: "%0.1f%%", store.syncingPercentage * 100))
                    .font(.custom(FontFamily.Inter.black.name, size: 10))
                    .foregroundColor(Asset.Colors.primary.color)
                
                ProgressView(value: store.syncingPercentage, total: 1.0)
                    .progressViewStyle(ZashiSyncingProgressStyle())
            }
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    SyncProgressView(
        store:
            StoreOf<SyncProgress>(
                initialState: .init(
                    lastKnownSyncPercentage: Float(0.43),
                    synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41, false)),
                    syncStatusMessage: "Syncing"
                )
            ) {
                SyncProgress()
            }
    )
    .background(.red)
}

// MARK: - Store

extension SyncProgress {
    public static var initial = StoreOf<SyncProgress>(
        initialState: .initial
    ) {
        SyncProgress()
    }
}

// MARK: - Placeholders

extension SyncProgress.State {
    public static let initial = SyncProgress.State(
        lastKnownSyncPercentage: 0,
        synchronizerStatusSnapshot: .initial
    )
}
