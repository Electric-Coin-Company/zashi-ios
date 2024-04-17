//
//  HideBalancesLiveKey.swift
//
//
//  Created by Lukáš Korba on 11.11.2023.
//

import Foundation
import ComposableArchitecture
import Combine
import UserDefaults

extension HideBalancesClient: DependencyKey {
    public static var liveValue: Self {
        let storage = CurrentValueSubject<Bool, Never>(false)

        return .init(
            prepare: {
                @Dependency(\.userDefaults) var userDefaults

                if let value = userDefaults.objectForKey(Constants.udHideBalances) as? Bool {
                    storage.value = value
                }
            },
            value: { storage },
            updateValue: {
                @Dependency(\.userDefaults) var userDefaults

                userDefaults.setValue($0, Constants.udHideBalances)
                
                storage.value = $0
            }
        )
    }
}
