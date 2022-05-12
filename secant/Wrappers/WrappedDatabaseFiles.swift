//
//  WrappedDatabaseFiles.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.05.2022.
//

import Foundation
import ZcashLightClientKit

struct WrappedDatabaseFiles {
    let documentsDirectory: () throws -> URL
    let cacheDbURLFor: (ZcashNetwork) throws -> URL
    let dataDbURLFor: (ZcashNetwork) throws -> URL
    let outputParamsURLFor: (ZcashNetwork) throws -> URL
    let pendingDbURLFor: (ZcashNetwork) throws -> URL
    let spendParamsURLFor: (ZcashNetwork) throws -> URL
    let areDbFilesPresentFor: (ZcashNetwork) throws -> Bool
    let nukeDbFilesFor: (ZcashNetwork) throws -> Void
}

extension WrappedDatabaseFiles {
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
    
    static var throwing = WrappedDatabaseFiles(
        documentsDirectory: {
            throw DatabaseFiles.DatabaseFilesError.getDocumentsURL
        },
        cacheDbURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getCacheURL
        },
        dataDbURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getDataURL
        },
        outputParamsURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getOutputParamsURL
        },
        pendingDbURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getPendingURL
        },
        spendParamsURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getSpendParamsURL
        },
        areDbFilesPresentFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.filesPresentCheck
        },
        nukeDbFilesFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.nukeFiles
        }
    )
}
