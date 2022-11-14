//
//  DatabaseFilesMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

extension DatabaseFilesClient {
    static let throwing = DatabaseFilesClient(
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
