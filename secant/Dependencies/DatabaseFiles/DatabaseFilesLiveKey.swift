//
//  DatabaseFilesLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture

extension DatabaseFilesClient: DependencyKey {
    static let liveValue = DatabaseFilesClient.live()
        
    static func live(databaseFiles: DatabaseFiles = DatabaseFiles(fileManager: .live)) -> Self {
        Self(
            documentsDirectory: {
                try databaseFiles.documentsDirectory()
            },
            cacheDbURLFor: { network in
                try databaseFiles.cacheDbURL(for: network)
            },
            dataDbURLFor: { network in
                try databaseFiles.dataDbURL(for: network)
            },
            outputParamsURLFor: { network in
                try databaseFiles.outputParamsURL(for: network)
            },
            pendingDbURLFor: { network in
                try databaseFiles.pendingDbURL(for: network)
            },
            spendParamsURLFor: { network in
                try databaseFiles.spendParamsURL(for: network)
            },
            areDbFilesPresentFor: { network in
                try databaseFiles.areDbFilesPresent(for: network)
            },
            nukeDbFilesFor: { network in
                try databaseFiles.nukeDbFiles(for: network)
            }
        )
    }
}
