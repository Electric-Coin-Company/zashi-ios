//
//  LogsHandlerLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import ComposableArchitecture

extension LogsHandlerClient: DependencyKey {
    static let liveValue = LogsHandlerClient(
        exportAndStoreLogs: { tempSDKDir, tempTCADir, tempWalletDir in
            async let sdkLogs = LogsHandlerClient.exportAndStoreLogsFor(key: LoggerConstants.sdkLogs, atURL: tempSDKDir)
            async let tcaLogs = LogsHandlerClient.exportAndStoreLogsFor(key: LoggerConstants.tcaLogs, atURL: tempTCADir)
            async let walletLogs = LogsHandlerClient.exportAndStoreLogsFor(key: LoggerConstants.walletLogs, atURL: tempWalletDir)

            let logs = try await [sdkLogs, tcaLogs, walletLogs]
            
            try logs.forEach { logsHandler in
                try logsHandler.result.write(to: logsHandler.dir, atomically: true, encoding: String.Encoding.utf8)
            }
        }
    )
}

private extension LogsHandlerClient {
    static func exportAndStoreLogsFor(key: String, atURL: URL) async throws -> (result: String, dir: URL) {
        let logsStr = try await LogStore.exportCategory(key)
        
        var result = ""
        logsStr?.forEach({ line in
            result.append(line)
            result.append("\n\n")
        })
        
        return (result: result, dir: atURL)
    }
}
