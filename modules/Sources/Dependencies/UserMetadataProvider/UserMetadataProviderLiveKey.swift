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
            store: { try ums.store(account: $0) },
            load: { try ums.load(account: $0) },
            resetAccount: { try ums.resetAccount($0) },
            reset: { try ums.reset() },
            isBookmarked: { ums.isBookmarked(txId: $0) },
            toggleBookmarkFor: { ums.toggleBookmarkFor(txId: $0) },
            annotationFor: { ums.annotationFor(txId: $0) },
            addAnnotationFor: { ums.add(annotation: $0, for: $1) },
            deleteAnnotationFor: { ums.deleteAnnotationFor(txId: $0) },
            isRead: { ums.isRead(txId: $0, txTimestamp: $1) },
            readTx: { ums.readTx(txId: $0) },
            isSwapTransaction: { ums.isSwapTransaction(txId: $0) },
            markTransactionAsSwapFor: { ums.markTransactionAsSwapFor(txId: $0, provider: $1) },
            lastUsedAssetHistory: { ums.lastUsedAssetHistory },
            addLastUsedSwapAsset: { ums.addLastUsedSwap(asset: $0) }
        )
    }()
}

extension UserMetadataStorage {
    public static let live = UserMetadataStorage()
}
