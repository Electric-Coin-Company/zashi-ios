//
//  WrappedSecItem.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.04.2022.
//

import Foundation
import Security

struct WrappedSecItem {
    let copyMatching: (CFDictionary, inout CFTypeRef?) -> OSStatus
    let add: (CFDictionary, inout CFTypeRef?) -> OSStatus
    let update: (CFDictionary, CFDictionary) -> OSStatus
    let delete: (CFDictionary) -> OSStatus
}

extension WrappedSecItem {
    static let live = WrappedSecItem(
        copyMatching: { query, result in
            SecItemCopyMatching(query, &result)
        },
        add: { attributes, result in
            SecItemAdd(attributes, &result)
        },
        update: { query, attributesToUpdate in
            SecItemUpdate(query, attributesToUpdate)
        },
        delete: { query in
            SecItemDelete(query)
        }
    )
}
