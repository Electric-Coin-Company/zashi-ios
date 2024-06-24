//
//  ExportLogs.swift
//
//
//  Created by Lukáš Korba on 06-20-2024.
//

import ComposableArchitecture

import Generated
import ZcashLightClientKit

// MARK: Alerts

extension AlertState where Action == ExportLogs.Action {
    public static func failed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.ExportLogs.Alert.Failed.title)
        } message: {
            TextState(L10n.ExportLogs.Alert.Failed.message(error.detailedMessage))
        }
    }
}

// MARK: Placeholders

extension ExportLogs.State {
    public static var initial: Self {
        .init()
    }
}
