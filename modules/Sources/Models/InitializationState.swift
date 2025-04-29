//
//  InitializationState.swift
//  Zashi
//
//  Created by Lukáš Korba on 30.03.2022.
//

import Foundation

public enum AppStartState: Equatable {
    case backgroundTask
    case didEnterBackground
    case didFinishLaunching
    case unknown
    case willEnterForeground
}

public enum InitializationState: Equatable {
    case failed
    case filesMissing
    case initialized
    case keysMissing
    case osStatus(OSStatus)
    case uninitialized
}

public enum SDKInitializationError: Error {
    case failed
}
