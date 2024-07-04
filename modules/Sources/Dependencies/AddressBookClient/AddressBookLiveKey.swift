//
//  AddressBookLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

import UserDefaults
import Models

extension AddressBookClient: DependencyKey {
    private enum Constants {
        static let udAddressBookRoot = "udAddressBookRoot"
    }
    
    public enum AddressBookError: Error {
        case alreadyExists
    }
    
    public static let liveValue: AddressBookClient = Self.live()
    
    public static func live() -> Self {
        @Dependency(\.userDefaults) var userDefaults
        
        return Self(
            all: {
                AddressBookClient.allRecipients(udc: userDefaults)
            },
            deleteRecipient: { recipientToDelete in
                var all = AddressBookClient.allRecipients(udc: userDefaults)
                all.remove(recipientToDelete)

                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(all) {
                    userDefaults.setValue(encoded, Constants.udAddressBookRoot)
                }
            },
            name: { address in
                AddressBookClient.allRecipients(udc: userDefaults).first {
                    $0.id == address
                }?.name
            },
            recipientExists: { AddressBookClient.recipientExists($0, udc: userDefaults) },
            storeRecipient: {
                guard !AddressBookClient.recipientExists($0, udc: userDefaults) else {
                    return
                }
                
                var all = AddressBookClient.allRecipients(udc: userDefaults)
                
                let countBefore = all.count
                all.append($0)
                
                // the list is the same = not new address but mayne new name to be updated
                if countBefore == all.count {
                    all.remove(id: $0.id)
                    all.append($0)
                }
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(all) {
                    userDefaults.setValue(encoded, Constants.udAddressBookRoot)
                }
            }
        )
    }
    
    private static func allRecipients( udc: UserDefaultsClient) -> IdentifiedArrayOf<ABRecord> {
        guard let root = udc.objectForKey(Constants.udAddressBookRoot) as? Data else {
            return []
        }
        
        let decoder = JSONDecoder()
        if let loadedList = try? decoder.decode([ABRecord].self, from: root) {
            return IdentifiedArrayOf(uniqueElements: loadedList)
        } else {
            return []
        }
    }
    
    private static func recipientExists(_ recipient: ABRecord, udc: UserDefaultsClient) -> Bool {
        AddressBookClient.allRecipients(udc: udc).firstIndex(of: recipient) != nil
    }
}
