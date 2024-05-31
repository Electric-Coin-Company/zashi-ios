//
//  WalletStatusPanelLiveKey.swift
//  
//
//  Created by Lukáš Korba on 19.12.2023.
//

import Foundation
import ComposableArchitecture
import Combine

extension WalletStatusPanelClient: DependencyKey {
    public static var liveValue: Self {
        let storage = CurrentValueSubject<WalletStatus, Never>(.none)

        return .init(
            value: { storage },
            updateValue: { storage.value = $0 }
        )
    }
}
