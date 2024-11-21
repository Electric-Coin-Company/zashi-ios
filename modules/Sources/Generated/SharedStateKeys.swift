//
//  SharedStateKeys.swift
//
//
//  Created by Lukáš Korba on 05-09-2024
//

import Foundation

public extension String {
    static let exchangeRate = "sharedStateKey_exchangeRate"
    static let sensitiveContent = "udHideBalances"
    static let walletStatus = "sharedStateKey_walletStatus"
    static let flexaAccountId = "sharedStateKey_flexaAccountId"
    static let addressBookContacts = "sharedStateKey_addressBookContacts"
    static let toast = "sharedStateKey_toast"
    static let featureFlags = "sharedStateKey_featureFlags"
    static let lastAuthenticationTimestamp = "sharedStateKey_lastAuthenticationTimestamp"
    static let account = "sharedStateKey_account"
}
