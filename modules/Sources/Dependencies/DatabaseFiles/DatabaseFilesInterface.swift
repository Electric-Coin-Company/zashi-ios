//
//  DatabaseFilesInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var databaseFiles: DatabaseFilesClient {
        get { self[DatabaseFilesClient.self] }
        set { self[DatabaseFilesClient.self] = newValue }
    }
}

public struct DatabaseFilesClient {
    public let documentsDirectory: () -> URL
    public let fsBlockDbRootFor: (ZcashNetwork) -> URL
    public let cacheDbURLFor: (ZcashNetwork) -> URL
    public let dataDbURLFor: (ZcashNetwork) -> URL
    public let outputParamsURLFor: (ZcashNetwork) -> URL
    public let pendingDbURLFor: (ZcashNetwork) -> URL
    public let spendParamsURLFor: (ZcashNetwork) -> URL
    public var areDbFilesPresentFor: (ZcashNetwork) -> Bool
}
