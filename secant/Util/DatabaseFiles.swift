//
//  DatabaseFiles.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.04.2022.
//

import Foundation
import ZcashLightClientKit

struct DatabaseFiles {
    enum DatabaseFilesError: Error {
        case getDocumentsURL
        case getCacheURL
        case getDataURL
        case getOutputParamsURL
        case getPendingURL
        case getSpendParamsURL
        case nukeFiles
        case filesPresentCheck
    }
    
    private let fileManager: WrappedFileManager
    
    init(fileManager: WrappedFileManager) {
        self.fileManager = fileManager
    }
    
    func documentsDirectory() throws -> URL {
        do {
            return try fileManager.url(.documentDirectory, .userDomainMask, nil, true)
        } catch {
            throw DatabaseFilesError.getDocumentsURL
        }
    }

    func cacheDbURL(for network: ZcashNetwork) throws -> URL {
        do {
            return try documentsDirectory()
                .appendingPathComponent(
                    "\(network.constants.defaultDbNamePrefix)cache.db",
                    isDirectory: false
                )
        } catch {
            throw DatabaseFilesError.getCacheURL
        }
    }

    func dataDbURL(for network: ZcashNetwork) throws -> URL {
        do {
            return try documentsDirectory()
                .appendingPathComponent(
                    "\(network.constants.defaultDbNamePrefix)data.db",
                    isDirectory: false
                )
        } catch {
            throw DatabaseFilesError.getDataURL
        }
    }

    func outputParamsURL(for network: ZcashNetwork) throws -> URL {
        do {
            return try documentsDirectory()
                .appendingPathComponent(
                    "\(network.constants.defaultDbNamePrefix)sapling-output.params",
                    isDirectory: false
                )
        } catch {
            throw DatabaseFilesError.getOutputParamsURL
        }
    }

    func pendingDbURL(for network: ZcashNetwork) throws -> URL {
        do {
            return try documentsDirectory()
                .appendingPathComponent(
                    "\(network.constants.defaultDbNamePrefix)pending.db",
                    isDirectory: false
                )
        } catch {
            throw DatabaseFilesError.getPendingURL
        }
    }

    func spendParamsURL(for network: ZcashNetwork) throws -> URL {
        do {
            return try documentsDirectory()
                .appendingPathComponent(
                    "\(network.constants.defaultDbNamePrefix)sapling-spend.params",
                    isDirectory: false
                )
        } catch {
            throw DatabaseFilesError.getSpendParamsURL
        }
    }

    func areDbFilesPresent(for network: ZcashNetwork) throws -> Bool {
        do {
            let dataDbURL = try dataDbURL(for: network)
            return fileManager.fileExists(dataDbURL.path)
        } catch {
            throw DatabaseFilesError.filesPresentCheck
        }
    }
    
    func nukeDbFiles(for network: ZcashNetwork) throws {
        do {
            let cacheDbURL = try cacheDbURL(for: network)
            let dataDbURL = try dataDbURL(for: network)
            let pendingDbURL = try pendingDbURL(for: network)
            try fileManager.removeItem(cacheDbURL)
            try fileManager.removeItem(dataDbURL)
            try fileManager.removeItem(pendingDbURL)
        } catch {
            throw DatabaseFilesError.nukeFiles
        }
    }
}

struct DatabaseFilesInteractor {
    let documentsDirectory: () throws -> URL
    let cacheDbURLFor: (ZcashNetwork) throws -> URL
    let dataDbURLFor: (ZcashNetwork) throws -> URL
    let outputParamsURLFor: (ZcashNetwork) throws -> URL
    let pendingDbURLFor: (ZcashNetwork) throws -> URL
    let spendParamsURLFor: (ZcashNetwork) throws -> URL
    let areDbFilesPresentFor: (ZcashNetwork) throws -> Bool
    let nukeDbFilesFor: (ZcashNetwork) throws -> Void
}

extension DatabaseFilesInteractor {
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
    
    static var throwing = DatabaseFilesInteractor(
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
