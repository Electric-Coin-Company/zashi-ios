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
            loadAddressBookContacts: {
                let fileManager = FileManager.default

                guard let containerURL = path(fileManager) else {
                    throw RemoteStorageError.containerURL
                }

                guard fileManager.fileExists(atPath: containerURL.path) else {
                    throw RemoteStorageError.fileDoesntExist
                }

//                try fileManager.startDownloadingUbiquitousItem(at: containerURL)

                return try Data(contentsOf: containerURL)
            },
            storeAddressBookContacts: { data in
                let fileManager = FileManager.default

                guard let containerURL = path(fileManager) else {
                    throw RemoteStorageError.containerURL
                }

                try data.write(to: containerURL)
            }
        )
    }
    
    private static func path(_ fileManager: FileManager) -> URL? {
        fileManager.url(
            forUbiquityContainerIdentifier: Constants.ubiquityContainerIdentifier)?.appendingPathComponent("Documents").appendingPathComponent(Constants.component)
    }
}
