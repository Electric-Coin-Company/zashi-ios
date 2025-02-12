//
//  RootUserMetadata.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-05.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Generated
import Models

extension Root {
    enum UMConstants {
        static let userMetadataSyncTime: TimeInterval = 60 * 10 // every 10 minutes
    }

    public func userMetadataReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .loadUserMetadata:
                return .merge(
//                    .publisher {
//                        Timer.publish(every: UMConstants.userMetadataSyncTime, on: .main, in: .default)
//                            .autoconnect()
//                            .map { Root.Action.userMetadataSync($0) }
//                    }
//                    .cancellable(id: state.CancelUMTimerId),
                    .run { send in
                        do {
                            try await userMetadataProvider.load()
                        } catch {
                            
                        }
                    }
                )
                
            case .userMetadataSync(let timestamp):
                guard let lastUserMetadataSyncTimestamp = state.lastUserMetadataSyncTimestamp else {
                    state.lastUserMetadataSyncTimestamp = Date().timeIntervalSince1970
                    return .none
                }
                return .none

            default: return .none
            }
        }
    }
}
