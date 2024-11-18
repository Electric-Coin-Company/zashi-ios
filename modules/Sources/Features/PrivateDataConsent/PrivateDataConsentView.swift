//
//  PrivateDataConsentView.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import ExportLogs

public struct PrivateDataConsentView: View {
    @Perception.Bindable var store: StoreOf<PrivateDataConsent>
    
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<PrivateDataConsent>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L10n.PrivateDataConsent.title)
                        .zFont(.semiBold, size: 24, style: Design.Text.primary)
                        .padding(.top, 40)
                    
                    Text(L10n.PrivateDataConsent.message1)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 12)
                    
                    Text(L10n.PrivateDataConsent.message2)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 8)
                    
                    Text(L10n.PrivateDataConsent.message3)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 8)
                    
                    Text(L10n.PrivateDataConsent.message4)
                        .zFont(size: 14, style: Design.Text.primary)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    ZashiToggle(
                        isOn: $store.isAcknowledged,
                        label: L10n.PrivateDataConsent.confirmation
                    )
                    .padding(.bottom, 24)
                    .padding(.leading, 1)
                    
                    if store.isExportingData {
                        ZashiButton(
                            L10n.Settings.exportPrivateData,
                            type: .secondary,
                            accessoryView: ProgressView()
                        ) {
                            store.send(.exportRequested)
                        }
                        .disabled(true)
                        .padding(.bottom, 8)
                    } else {
                        ZashiButton(
                            L10n.Settings.exportPrivateData,
                            type: .secondary
                        ) {
                            store.send(.exportRequested)
                        }
                        .disabled(!store.isExportPossible)
                        .padding(.bottom, 8)
                    }
                    
#if DEBUG
                    if store.isExportingLogs {
                        ZashiButton(
                            L10n.Settings.exportLogsOnly,
                            accessoryView: ProgressView()
                        ) {
                            store.send(.exportLogsRequested)
                        }
                        .disabled(true)
                        .padding(.bottom, 20)
                    } else {
                        ZashiButton(
                            L10n.Settings.exportLogsOnly
                        ) {
                            store.send(.exportLogsRequested)
                        }
                        .disabled(!store.isExportPossible)
                        .padding(.bottom, 20)
                    }
#endif
                }
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear { store.send(.onAppear)}
            .walletStatusPanel()

            shareLogsView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.PrivateDataConsent.screenTitle.uppercased())
    }
}

private extension PrivateDataConsentView {
    @ViewBuilder func shareLogsView() -> some View {
        if store.exportBinding {
            UIShareDialogView(activityItems: store.exportURLs) {
                store.send(.shareFinished)
            }
            // UIShareDialogView only wraps UIActivityViewController presentation
            // so frame is set to 0 to not break SwiftUIs layout
            .frame(width: 0, height: 0)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    PrivateDataConsentView(store: .demo)
}

// MARK: - Store

extension StoreOf<PrivateDataConsent> {
    public static var demo = StoreOf<PrivateDataConsent>(
        initialState: .initial
    ) {
        PrivateDataConsent()
    }
}

// MARK: - Placeholders

extension PrivateDataConsent.State {
    public static let initial = PrivateDataConsent.State(
        dataDbURL: [],
        exportBinding: false,
        exportLogsState: .initial
    )
}
