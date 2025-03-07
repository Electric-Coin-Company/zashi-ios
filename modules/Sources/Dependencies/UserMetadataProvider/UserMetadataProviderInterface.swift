//
//  UserMetadataProviderInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-28.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var userMetadataProvider: UserMetadataProviderClient {
        get { self[UserMetadataProviderClient.self] }
        set { self[UserMetadataProviderClient.self] = newValue }
    }
}

@DependencyClient
public struct UserMetadataProviderClient {
    // General
    public let store: (Account) throws -> Void
    public let load: (Account) throws -> Void
    public let resetAccount: (Account) throws -> Void
    public let reset: () throws -> Void

    // Bookmarking
    public let isBookmarked: (String) -> Bool
    public let toggleBookmarkFor: (String) -> Void
    
    // Annotations
    public let annotationFor: (String) -> String?
    public let addAnnotationFor: (String, String) -> Void
    public let deleteAnnotationFor: (String) -> Void

    // Read
    public let isRead: (String, TimeInterval?) -> Bool
    public let readTx: (String) -> Void
}
