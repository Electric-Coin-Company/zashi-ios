//
//  HideBalancesInterface.swift
//
//
//  Created by Lukáš Korba on 11.11.2023.
//

import Foundation
import ComposableArchitecture
import Combine

extension DependencyValues {
    public var hideBalances: HideBalancesClient {
        get { self[HideBalancesClient.self] }
        set { self[HideBalancesClient.self] = newValue }
    }
}

@DependencyClient
public struct HideBalancesClient {
    public enum Constants {
        static let udHideBalances = "udHideBalances"
    }

    public var prepare: @Sendable () -> Void
    public var value: @Sendable () -> CurrentValueSubject<Bool, Never> = { CurrentValueSubject(false) }
    public var updateValue: @Sendable (Bool) -> Void
}
