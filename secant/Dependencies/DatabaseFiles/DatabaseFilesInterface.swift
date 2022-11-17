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
    var databaseFiles: DatabaseFilesClient {
        get { self[DatabaseFilesClient.self] }
        set { self[DatabaseFilesClient.self] = newValue }
    }
}

struct DatabaseFilesClient {
    let documentsDirectory: () throws -> URL
    let cacheDbURLFor: (ZcashNetwork) throws -> URL
    let dataDbURLFor: (ZcashNetwork) throws -> URL
    let outputParamsURLFor: (ZcashNetwork) throws -> URL
    let pendingDbURLFor: (ZcashNetwork) throws -> URL
    let spendParamsURLFor: (ZcashNetwork) throws -> URL
    var areDbFilesPresentFor: (ZcashNetwork) throws -> Bool
    let nukeDbFilesFor: (ZcashNetwork) throws -> Void
}
