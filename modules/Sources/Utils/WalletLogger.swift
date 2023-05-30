//
//  WalletLogger.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 23.01.2023.
//

import Foundation
import ZcashLightClientKit
import os

public enum LoggerConstants {
    public static let sdkLogs = "sdkLogs"
    public static let tcaLogs = "tcaLogs"
    public static let walletLogs = "walletLogs"
}

public var walletLogger: ZcashLightClientKit.Logger?

public enum LoggerProxy {
    public static func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.debug(message, file: file, function: function, line: line)
    }
    
    public static func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.info(message, file: file, function: function, line: line)
    }
    
    public static func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.event(message, file: file, function: function, line: line)
    }
    
    public static func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.warn(message, file: file, function: function, line: line)
    }
    
    public static func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.error(message, file: file, function: function, line: line)
    }
}
