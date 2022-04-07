//
//  DatabaseFiles.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.04.2022.
//

import Foundation

struct DatabaseFiles {
    enum DatabaseFilesError: Error {
        case getDocumentsURL
        case getDataURL
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

    func dataDbURL(for network: String) throws -> URL {
        do {
            return try documentsDirectory().appendingPathComponent("zcash.\(network).data.db", isDirectory: false)
        } catch {
            throw DatabaseFilesError.getDataURL
        }
    }

    func areDbFilesPresent(for network: String) throws -> Bool {
        do {
            let dataDatabaseURL = try dataDbURL(for: network)
            return fileManager.fileExists(dataDatabaseURL.path)
        } catch {
            throw DatabaseFilesError.filesPresentCheck
        }
    }
    
    func nukeDbFiles(for network: String) throws {
        do {
            let dataDatabaseURL = try dataDbURL(for: network)
            try fileManager.removeItem(dataDatabaseURL)
        } catch {
            throw DatabaseFilesError.nukeFiles
        }
    }
}

struct DatabaseFilesInteractor {
    let documentsDirectory: () throws -> URL
    let dataDbURLFor: (String) throws -> URL
    let areDbFilesPresentFor: (String) throws -> Bool
    let nukeDbFilesFor: (String) throws -> Void
}

extension DatabaseFilesInteractor {
    static func live(databaseFiles: DatabaseFiles = DatabaseFiles(fileManager: .live)) -> Self {
        Self(
            documentsDirectory: {
                try databaseFiles.documentsDirectory()
            },
            dataDbURLFor: { network in
                try databaseFiles.dataDbURL(for: network)
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
        dataDbURLFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.getDataURL
        },
        areDbFilesPresentFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.filesPresentCheck
        },
        nukeDbFilesFor: { _ in
            throw DatabaseFiles.DatabaseFilesError.nukeFiles
        }
    )
}
