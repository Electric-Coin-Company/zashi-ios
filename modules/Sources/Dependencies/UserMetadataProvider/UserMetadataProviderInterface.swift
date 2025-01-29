//
//  UserMetadataProviderInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-28.
//

import ComposableArchitecture

extension DependencyValues {
    public var userMetadataProvider: UserMetadataProviderClient {
        get { self[UserMetadataProviderClient.self] }
        set { self[UserMetadataProviderClient.self] = newValue }
    }
}

@DependencyClient
public struct UserMetadataProviderClient {
    // Bookmarking
    public let isBookmarked: (String) -> Bool
    public let toggleBookmarkFor: (String) -> Void
    
    // Annotations
    public let annotationFor: (String) -> String?
    public let addAnnotationFor: (String, String) -> Void
    public let deleteAnnotationFor: (String) -> Void

    // General
    public let store: () async throws -> Void
    public let load: () async throws -> Void
}
