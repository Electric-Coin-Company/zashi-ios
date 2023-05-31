//
//  SecItemClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.04.2022.
//

import Foundation
import Security

public struct SecItemClient {
    public let copyMatching: (CFDictionary, inout CFTypeRef?) -> OSStatus
    public let add: (CFDictionary, inout CFTypeRef?) -> OSStatus
    public let update: (CFDictionary, CFDictionary) -> OSStatus
    public let delete: (CFDictionary) -> OSStatus
    
    public init(
        copyMatching: @escaping (CFDictionary, inout CFTypeRef?) -> OSStatus,
        add: @escaping (CFDictionary, inout CFTypeRef?) -> OSStatus,
        update: @escaping (CFDictionary, CFDictionary) -> OSStatus,
        delete: @escaping (CFDictionary) -> OSStatus
    ) {
        self.copyMatching = copyMatching
        self.add = add
        self.update = update
        self.delete = delete
    }
}
