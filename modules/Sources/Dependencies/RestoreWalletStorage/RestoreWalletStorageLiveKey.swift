//
//  RestoreWalletStorageLiveKey.swift
//  
//
//  Created by Lukáš Korba on 19.12.2023.
//

import Foundation
import ComposableArchitecture
import Combine

extension RestoreWalletStorageClient: DependencyKey {
    public static var liveValue: Self {
        let storage = CurrentValueSubject<Bool, Never>(false)

        return .init(
            value: {
                AsyncStream { continuation in
                    let cancellable = storage.sink {
                        continuation.yield($0)
                    }

                    continuation.onTermination = { _ in
                        cancellable.cancel()
                    }
                }
            },
            updateValue: { storage.value = $0 }
        )
    }
}

extension AsyncStream<Bool> {
    static let placeholder = AsyncStream { continuation in continuation.finish() }
}
