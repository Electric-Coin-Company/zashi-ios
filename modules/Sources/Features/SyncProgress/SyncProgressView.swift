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
    var store: SyncProgressStore
    
    public init(store: SyncProgressStore) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 5) {
                HStack {
                    Text(viewStore.syncStatusMessage)
                        .font(.custom(FontFamily.Inter.regular.name, size: 10))
                    
                    if viewStore.isSyncing {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 11, height: 14)
                    }
                }
                .frame(height: 16)
                .padding(.bottom, 5)
                
                Text(String(format: "%0.1f%%", viewStore.syncingPercentage * 100))
                    .font(.custom(FontFamily.Inter.black.name, size: 10))
                    .foregroundColor(Asset.Colors.primary.color)
                
                ProgressView(value: viewStore.syncingPercentage, total: 1.0)
                    .progressViewStyle(ZashiSyncingProgressStyle())
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
    }
}

#Preview {
    SyncProgressView(
        store:
            SyncProgressStore(
                initialState: .init(
                    lastKnownSyncPercentage: Float(0.43),
                    synchronizerStatusSnapshot: SyncStatusSnapshot(.syncing(0.41)),
                    syncStatusMessage: "Syncing"
                )
            ) {
                SyncProgressReducer()
            }
    )
    .background(.red)
}
