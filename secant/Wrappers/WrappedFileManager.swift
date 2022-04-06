//
//  WrappedFileManager.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 07.04.2022.
//

import Foundation

struct WrappedFileManager {
    let url: (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL
    let fileExists: (String) -> Bool
    let removeItem: (URL) throws -> Void
}

extension WrappedFileManager {
    static let live = WrappedFileManager(
        url: { searchPathDirectory, searchPathDomainMask, appropriateForURL, shouldCreate in
            try FileManager.default.url(for: searchPathDirectory, in: searchPathDomainMask, appropriateFor: appropriateForURL, create: shouldCreate)
        },
        fileExists: { path in
            FileManager.default.fileExists(atPath: path)
        },
        removeItem: { url in
            try FileManager.default.removeItem(at: url)
        }
    )
}
