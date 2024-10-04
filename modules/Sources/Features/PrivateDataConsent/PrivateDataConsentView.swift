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
                Group {
                    ZashiIcon()
                        .padding(.top, walletStatus != .none ? 30 : 0)
                    
                    Text(L10n.PrivateDataConsent.title)
                        .font(.custom(FontFamily.Inter.semiBold.name, size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 35)
                    
                    Text(L10n.PrivateDataConsent.message)
                        .font(.custom(FontFamily.Inter.regular.name, size: 14))
                        .padding(.bottom, 10)
                        .lineSpacing(3)

                    Text(L10n.PrivateDataConsent.note)
                        .font(.custom(FontFamily.Inter.regular.name, size: 12))
                        .lineSpacing(2)

                    HStack {
                        ZashiToggle(
                            isOn: $store.isAcknowledged,
                            label: L10n.PrivateDataConsent.confirmation
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)

                    if store.isExportingData {
                        ZashiButton(
                            L10n.Settings.exportPrivateData,
                            type: .secondary,
                            accessoryView: ProgressView()
                        ) {
                            store.send(.exportRequested)
                        }
                        .disabled(true)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    } else {
                        ZashiButton(
                            L10n.Settings.exportPrivateData,
                            type: .secondary
                        ) {
                            store.send(.exportRequested)
                        }
                        .disabled(!store.isExportPossible)
                        .padding(.horizontal, 8)
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
                        .padding(.horizontal, 8)
                        .padding(.bottom, 50)
                    } else {
                        ZashiButton(
                            L10n.Settings.exportLogsOnly
                        ) {
                            store.send(.exportLogsRequested)
                        }
                        .disabled(!store.isExportPossible)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 50)
                    }
                    #endif
                }
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear {
                store.send(.onAppear)
            }
            .walletStatusPanel()

            shareLogsView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
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
