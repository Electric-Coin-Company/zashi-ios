//
//  UserMetadataProviderLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-01-28.
//

import ComposableArchitecture

extension UserMetadataProviderClient: DependencyKey {
    public static var liveValue: UserMetadataProviderClient = {
        let ums = UserMetadataStorage.live
        
        return UserMetadataProviderClient(
            store: { try await ums.store() },
            load: { try await ums.load() },
            isBookmarked: { ums.isBookmarked(txid: $0) },
            toggleBookmarkFor: { ums.toggleBookmarkFor(txid: $0) },
            annotationFor: { ums.annotationFor(txid: $0) },
            addAnnotationFor: { ums.add(annotation: $0, for: $1) },
            deleteAnnotationFor: { ums.deleteAnnotationFor(txid: $0) },
            isUnread: { ums.isUnread(txid: $0) },
            toggleUnreadFor: { ums.toggleUnreadFor(txid: $0) }
        )
    }()
}

extension UserMetadataStorage {
    public static let live = UserMetadataStorage(
    )
}
