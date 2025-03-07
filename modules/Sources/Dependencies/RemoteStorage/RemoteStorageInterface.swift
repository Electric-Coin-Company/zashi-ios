//
//  RemoteStorageInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-27-2024.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    public var remoteStorage: RemoteStorageClient {
        get { self[RemoteStorageClient.self] }
        set { self[RemoteStorageClient.self] = newValue }
    }
}

@DependencyClient
public struct RemoteStorageClient {
    public let loadDataFromFile: (String) throws -> Data
    public let storeDataToFile: (Data, String) throws -> Void
    public let removeFile: (String) throws -> Void
}
