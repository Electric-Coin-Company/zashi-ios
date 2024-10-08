//
//  ReadTransactionsStorageInterface.swift
//  
//
//  Created by Lukáš Korba on 11.11.2023.
//

import Foundation
import ComposableArchitecture
import Utils

extension DependencyValues {
    public var readTransactionsStorage: ReadTransactionsStorageClient {
        get { self[ReadTransactionsStorageClient.self] }
        set { self[ReadTransactionsStorageClient.self] = newValue }
    }
}

@DependencyClient
public struct ReadTransactionsStorageClient {
    public enum Constants {
        static let entityName = "ReadTransactionsStorageEntity"
        static let modelName = "ReadTransactionsStorageModel"
        static let availabilityEntityName = "ReadTransactionsStorageAvailabilityTimestampEntity"
    }
    
    public enum ReadTransactionsStorageError: Error {
        case createEntity
        case availability
    }
    
    public let markIdAsRead: (RedactableString) throws -> Void
    public var readIds: () throws -> [RedactableString: Bool]
    public var availabilityTimestamp: () throws -> TimeInterval
    public var resetZashi: () throws -> Void
}
