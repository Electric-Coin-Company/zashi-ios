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
    var store: PrivateDataConsentStore
    
    public init(store: PrivateDataConsentStore) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                Group {
                    ZashiIcon()
                        .padding(.top, viewStore.isRestoringWallet ? 30 : 0)
                    
                    Text(L10n.PrivateDataConsent.title)
                        .font(.custom(FontFamily.Archivo.semiBold.name, size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 35)
                    
                    Text(L10n.PrivateDataConsent.message)
                        .font(.custom(FontFamily.Archivo.regular.name, size: 14))
                        .padding(.bottom, 10)
                        .lineSpacing(3)

                    Text(L10n.PrivateDataConsent.note)
                        .font(.custom(FontFamily.Archivo.regular.name, size: 12))
                        .lineSpacing(2)

                    HStack {
                        Toggle(isOn: viewStore.$isAcknowledged, label: {
                            Text(L10n.PrivateDataConsent.confirmation)
                                .font(.custom(FontFamily.Inter.medium.name, size: 14))
                        })
                        .toggleStyle(CheckboxToggleStyle())
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)

                    Button {
                        viewStore.send(.exportRequested)
                    } label: {
                        HStack(spacing: 10) {
                            Text(L10n.Settings.exportPrivateData.uppercased())
                            if viewStore.isExportingData {
                                ProgressView()
                            }
                        }
                    }
                    .zcashStyle(.secondary)
                    .disabled(!viewStore.isExportPossible)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 25)

                    Button {
                        viewStore.send(.exportLogsRequested)
                    } label: {
                        HStack(spacing: 10) {
                            Text(L10n.Settings.exportLogsOnly.uppercased())
                            if viewStore.isExportingLogs {
                                ProgressView()
                            }
                        }
                    }
                    .zcashStyle()
                    .disabled(!viewStore.isExportPossible)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 60)
            }
            .padding(.vertical, 1)
            .zashiBack()
            .onAppear {
                viewStore.send(.onAppear)
            }
            .restoringWalletBadge(isOn: viewStore.isRestoringWallet, background: .pattern)

            shareLogsView(viewStore)
        }
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground(withPattern: true)
        .task { await store.send(.restoreWalletTask).finish() }
    }
}

private extension PrivateDataConsentView {
    @ViewBuilder func shareLogsView(_ viewStore: PrivateDataConsentViewStore) -> some View {
        if viewStore.exportBinding {
            UIShareDialogView(activityItems: viewStore.exportURLs) {
                viewStore.send(.shareFinished)
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
