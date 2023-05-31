//
//  LogsHandlerLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import ComposableArchitecture
import Utils

extension LogsHandlerClient: DependencyKey {
    public static let liveValue = LogsHandlerClient(
        exportAndStoreLogs: { sdkLogs, tcaLogs, walletLogs in
            // create a directory
            let logsURL = FileManager.default.temporaryDirectory.appendingPathComponent("logs")
            try FileManager.default.createDirectory(atPath: logsURL.path, withIntermediateDirectories: true)
            
            // export the logs
            async let sdkLogs = LogsHandlerClient.exportAndStoreLogsFor(
                key: sdkLogs,
                atURL: logsURL.appendingPathComponent("sdkLogs.txt")
            )
            async let tcaLogs = LogsHandlerClient.exportAndStoreLogsFor(
                key: tcaLogs,
                atURL: logsURL.appendingPathComponent("tcaLogs.txt")
            )
            async let walletLogs = LogsHandlerClient.exportAndStoreLogsFor(
                key: walletLogs,
                atURL: logsURL.appendingPathComponent("walletLogs.txt")
            )

            let logs = try await [sdkLogs, tcaLogs, walletLogs]
            
            // store the log files into the logs folder
            try logs.forEach { logsHandler in
                try logsHandler.result.write(to: logsHandler.dir, atomically: true, encoding: String.Encoding.utf8)
            }
            
            // zip the logs folder
            let coordinator = NSFileCoordinator()
            var zipError: NSError?
            var archiveURL: URL?
            
            archiveURL = await withCheckedContinuation { continuation in
                coordinator.coordinate(readingItemAt: logsURL, options: [.forUploading], error: &zipError) { zipURL in
                    do {
                        let tmpURL = try FileManager.default.url(
                            for: .itemReplacementDirectory,
                            in: .userDomainMask,
                            appropriateFor: zipURL,
                            create: true
                        )
                        .appendingPathComponent("logs.zip")
                        try FileManager.default.moveItem(at: zipURL, to: tmpURL)
                        continuation.resume(returning: tmpURL)
                    } catch {
                        continuation.resume(returning: nil)
                    }
                }
            }
            
            return archiveURL
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
