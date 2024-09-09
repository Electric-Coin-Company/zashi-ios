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

                    Button {
                        store.send(.exportRequested)
                    } label: {
                        HStack(spacing: 10) {
                            Text(L10n.Settings.exportPrivateData.uppercased())
                            if store.isExportingData {
                                ProgressView()
                            }
                        }
                    }
                    .zcashStyle(.secondary)
                    .disabled(!store.isExportPossible)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 25)

                    #if DEBUG
                    Button {
                        store.send(.exportLogsRequested)
                    } label: {
                        HStack(spacing: 10) {
                            Text(L10n.Settings.exportLogsOnly.uppercased())
                            if store.isExportingLogs {
                                ProgressView()
                            }
                        }
                    }
                    .zcashStyle()
                    .disabled(!store.isExportPossible)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 50)
                    #endif
                }
                .padding(.horizontal, 60)
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear {
                store.send(.onAppear)
            }
            .walletStatusPanel(background: .pattern)

            shareLogsView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
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
