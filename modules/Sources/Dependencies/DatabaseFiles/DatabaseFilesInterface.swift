//
//  DatabaseFilesInterface.swift
//  Zashi
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

@DependencyClient
public struct DatabaseFilesClient {
    public let documentsDirectory: () -> URL
    public let fsBlockDbRootFor: (ZcashNetwork) -> URL
    public let cacheDbURLFor: (ZcashNetwork) -> URL
    public var dataDbURLFor: (ZcashNetwork) -> URL = { _ in .emptyURL }
    public let outputParamsURLFor: (ZcashNetwork) -> URL
    public let pendingDbURLFor: (ZcashNetwork) -> URL
    public let spendParamsURLFor: (ZcashNetwork) -> URL
    public var toDirURLFor: (ZcashNetwork) -> URL = { _ in .emptyURL }
    public var areDbFilesPresentFor: (ZcashNetwork) -> Bool = { _ in false }
}
