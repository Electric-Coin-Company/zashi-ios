//
//  AppDelegateAction.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 27.03.2022.
//

import Foundation
import BackgroundTasks

public enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case didEnterBackground
    case willEnterForeground
    case backgroundTask(BGProcessingTask)
}
