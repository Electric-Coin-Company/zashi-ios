//
//  FileManagerClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 07.04.2022.
//

import Foundation

struct FileManagerClient {
    let url: (FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL
    let fileExists: (String) -> Bool
    let removeItem: (URL) throws -> Void
}
