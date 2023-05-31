//
//  LogsHandlerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.01.2023.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    public var logsHandler: LogsHandlerClient {
        get { self[LogsHandlerClient.self] }
        set { self[LogsHandlerClient.self] = newValue }
    }
}

public struct LogsHandlerClient {
    public let exportAndStoreLogs: (String, String, String) async throws -> URL?
    
    public init(exportAndStoreLogs: @escaping (String, String, String) async throws -> URL?) {
        self.exportAndStoreLogs = exportAndStoreLogs
    }
}
