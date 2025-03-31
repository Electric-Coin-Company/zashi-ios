//
//  ExportTransactionHistoryView.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-13.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents

public struct ExportTransactionHistoryView: View {
    @Perception.Bindable var store: StoreOf<ExportTransactionHistory>
    
    @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none

    public init(store: StoreOf<ExportTransactionHistory>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 0) {
                Text(L10n.TaxExport.taxFile)
                    .zFont(.semiBold, size: 24, style: Design.Text.primary)
                    .padding(.top, 40)
                
                Text(L10n.TaxExport.desc(store.accountName))
                    .zFont(size: 14, style: Design.Text.primary)
                    .padding(.top, 12)
                
                Spacer()
                
                if store.isExportingData {
                    ZashiButton(
                        L10n.TaxExport.download,
                        accessoryView: ProgressView()
                    ) {
                        store.send(.exportRequested)
                    }
                    .disabled(true)
                    .padding(.bottom, 24)
                } else {
                    ZashiButton(L10n.TaxExport.download) {
                        store.send(.exportRequested)
                    }
                    .disabled(!store.isExportPossible)
                    .padding(.bottom, 24)
                }
            }
            .zashiBack()
            //..walletstatusPanel()

            shareLogsView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .screenHorizontalPadding()
        .applyScreenBackground()
        .screenTitle(L10n.TaxExport.title)
    }
}

private extension ExportTransactionHistoryView {
    @ViewBuilder func shareLogsView() -> some View {
        if store.exportBinding {
            UIShareDialogView(activityItems:
                [ShareableURL(
                    url: store.dataURL,
                    title: L10n.TaxExport.taxFile,
                    desc: L10n.TaxExport.shareDesc(store.accountName)
                )]
            ) {
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
    ExportTransactionHistoryView(store: .initial)
}

// MARK: - Store

extension StoreOf<ExportTransactionHistory> {
    public static var initial = StoreOf<ExportTransactionHistory>(
        initialState: .initial
    ) {
        ExportTransactionHistory()
    }
}

// MARK: - Placeholders

extension ExportTransactionHistory.State {
    public static let initial = ExportTransactionHistory.State()
}
