//
//  TCALogging.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 23.01.2023.
//

import Foundation
import os
import ZcashLightClientKit
import Utils

extension OSLogger {
    static let live = OSLogger(logLevel: .debug, category: LoggerConstants.tcaLogs)

    func tcaDebug(_ message: String) {
        guard let oslog else { return }
        
        os_log(
            "%{public}@",
            log: oslog,
            message
        )
    }
}
