//
//  ZcashError+DetailedMessage.swift
//  
//
//  Created by Lukáš Korba on 24.03.2024.
//

import ZcashLightClientKit

public extension ZcashError {
    var detailedMessage: String {
        "[\(self.code.rawValue)] \(self.message)\n\(self)"
    }
    
    var isInsufficientBalance: Bool {
        detailedMessage.lowercased().contains("insufficient balance")
    }
}
