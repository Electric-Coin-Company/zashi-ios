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
    let documentsDirectory: () -> URL
    let fsBlockDbRootFor: (ZcashNetwork) -> URL
    let cacheDbURLFor: (ZcashNetwork) -> URL
    let dataDbURLFor: (ZcashNetwork) -> URL
    let outputParamsURLFor: (ZcashNetwork) -> URL
    let pendingDbURLFor: (ZcashNetwork) -> URL
    let spendParamsURLFor: (ZcashNetwork) -> URL
    var areDbFilesPresentFor: (ZcashNetwork) -> Bool
}
