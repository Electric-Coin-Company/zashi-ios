//
//  LogsHandlerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var logsHandler: LogsHandlerClient {
        get { self[LogsHandlerClient.self] }
        set { self[LogsHandlerClient.self] = newValue }
    }
}
struct LogsHandlerClient {
    let exportAndStoreLogs: () async throws -> URL?
}
