//
//  OSLogger_.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 23.01.2023.
//

import Foundation
import ZcashLightClientKit
import os

enum LoggerConstants {
    static let sdkLogs = "sdkLogs"
    static let tcaLogs = "tcaLogs"
    static let walletLogs = "walletLogs"
}

var walletLogger: ZcashLightClientKit.Logger?

enum LoggerProxy {
    static func debug(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.debug(message, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.info(message, file: file, function: function, line: line)
    }
    
    static func event(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.event(message, file: file, function: function, line: line)
    }
    
    static func warn(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.warn(message, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: StaticString = #file, function: StaticString = #function, line: Int = #line) {
        walletLogger?.error(message, file: file, function: function, line: line)
    }
}

// TODO: [#529] the swiftlint rule as well as OSLogger_ will be removed once secant adopts latest SDK changes https://github.com/zcash/secant-ios-wallet/issues/529
// swiftlint:disable:next type_name
class OSLogger_: ZcashLightClientKit.Logger {
    enum LogLevel: Int {
        case debug
        case error
        case warning
        case event
        case info
    }

    private(set) var oslog: OSLog?
    
    var level: LogLevel
    
    init(logLevel: LogLevel, category: String) {
        self.level = logLevel
        if let bundleName = Bundle.main.bundleIdentifier {
            self.oslog = OSLog(subsystem: bundleName, category: category)
        }
    }

    func debug(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard level.rawValue == LogLevel.debug.rawValue else { return }
        log(level: "DEBUG 🐞", message: message, file: file, function: function, line: line)
    }
    
    func error(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard level.rawValue <= LogLevel.error.rawValue else { return }
        log(level: "ERROR 💥", message: message, file: file, function: function, line: line)
    }
    
    func warn(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard level.rawValue <= LogLevel.warning.rawValue else { return }
        log(level: "WARNING ⚠️", message: message, file: file, function: function, line: line)
    }

    func event(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard level.rawValue <= LogLevel.event.rawValue else { return }
        log(level: "EVENT ⏱", message: message, file: file, function: function, line: line)
    }
    
    func info(
        _ message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard level.rawValue <= LogLevel.info.rawValue else { return }
        log(level: "INFO ℹ️", message: message, file: file, function: function, line: line)
    }
    
    private func log(
        level: String,
        message: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: Int = #line
    ) {
        guard let oslog else { return }
        
        let fileName = (String(describing: file) as NSString).lastPathComponent
        
        os_log(
            "[%{public}@] %{public}@ - %{public}@ - Line: %{public}d -> %{public}@",
            log: oslog,
            level,
            fileName,
            String(describing: function),
            line,
            message
        )
    }
}
