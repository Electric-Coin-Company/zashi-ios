//
//  TCALogger.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 23.01.2023.
//

import Foundation
import os

class TCALogger: OSLogger_ { }

extension TCALogger {
    static let live = TCALogger(logLevel: .debug, category: LoggerConstants.tcaLogs)

    func tcaDebug(_ message: String) {
        guard let oslog else { return }
        
        os_log(
            "%{public}@",
            log: oslog,
            message
        )
    }
}
