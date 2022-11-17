//
//  SecItemClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.04.2022.
//

import Foundation
import Security

struct SecItemClient {
    let copyMatching: (CFDictionary, inout CFTypeRef?) -> OSStatus
    let add: (CFDictionary, inout CFTypeRef?) -> OSStatus
    let update: (CFDictionary, CFDictionary) -> OSStatus
    let delete: (CFDictionary) -> OSStatus
}
