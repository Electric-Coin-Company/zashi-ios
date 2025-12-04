//
//  PartnerKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-17-2024.
//

import Foundation

public struct PartnerKeys {
    private enum Constants {
        static let cbProjectId = "cbProjectId"
        static let flexaPublishableKey = "flexaPublishableKey"
        static let flexaPublishableTestKey = "flexaPublishableTestKey"
        static let nearKey = "nearKey"
        static let cmcKey = "cmcKey"
    }
    
    public static var cbProjectId: String? {
        PartnerKeys.value(for: Constants.cbProjectId)
    }
    
    public static var flexaPublishableKey: String? {
        PartnerKeys.value(for: Constants.flexaPublishableKey)
    }
    
    public static var flexaPublishableTestKey: String? {
        PartnerKeys.value(for: Constants.flexaPublishableTestKey)
    }
    
    public static var nearKey: String? {
        PartnerKeys.value(for: Constants.nearKey)
    }
    
    public static var cmcKey: String? {
        PartnerKeys.value(for: Constants.cmcKey)
    }
}

private extension PartnerKeys {
    static func value(for key: String) -> String? {
        let fileName = "PartnerKeys.plist"

        guard
            let configFile = Bundle.main.url(forResource: fileName, withExtension: nil),
            let properties = NSDictionary(contentsOf: configFile),
            let key = properties[key] as? String
        else {
            return nil
        }

        return key
    }
}
