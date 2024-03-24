//
//  ZcashError+DetailedMessage.swift
//  
//
//  Created by Lukáš Korba on 24.03.2024.
//

import ZcashLightClientKit

extension ZcashError {
    public var detailedMessage: String {
        "[\(self.code.rawValue)] \(self.message)\n\(self)"
    }
}
