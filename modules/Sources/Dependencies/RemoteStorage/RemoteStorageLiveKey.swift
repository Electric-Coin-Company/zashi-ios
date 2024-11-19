//
//  RemoteStorageLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-27-2024.
//

import Foundation
import ComposableArchitecture

extension RemoteStorageClient: DependencyKey {
    private enum Constants {
        static let ubiquityContainerIdentifier = "iCloud.com.electriccoinco.zashi"
        static let component = "AddressBookData"
    }
    
    public enum RemoteStorageError: Error {
        case containerURL
        case fileDoesntExist
    }
    
    public static let liveValue: RemoteStorageClient = Self.live()
    
    public static func live() -> Self {
        return Self(
            loadAddressBookContacts: { filename in
                let fileManager = FileManager.default

                guard let containerURL = path(fileManager, filename: filename) else {
                    throw RemoteStorageError.containerURL
                }

                guard fileManager.fileExists(atPath: containerURL.path) else {
                    throw RemoteStorageError.fileDoesntExist
                }

                return try Data(contentsOf: containerURL)
            },
            storeAddressBookContacts: { data, filename in
                let fileManager = FileManager.default

                guard let containerURL = path(fileManager, filename: filename) else {
                    throw RemoteStorageError.containerURL
                }

                try data.write(to: containerURL)
            }
        )
    }
    
    private static func path(_ fileManager: FileManager, filename: String) -> URL? {
        fileManager.url(
            forUbiquityContainerIdentifier: Constants.ubiquityContainerIdentifier)?.appendingPathComponent("Documents").appendingPathComponent(filename)
    }
}
