//
//  WhatsNewProviderLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

extension WhatsNewProviderClient: DependencyKey {
    public static let liveValue = Self(
        latest: {
            WhatsNewProviderClient.releases().releases.first ?? .zero
        },
        all: {
            WhatsNewProviderClient.releases()
        }
    )
    
    private static func releases() -> WhatNewReleases {
        // default what's new file with EN localization
        var fileName = "whatsNew"

        // check the file if this localization exists
        if let preferredLanguageCode = Locale.preferredLanguages.first?.split(separator: "-").first {
            var localizedWhatsNewFileName = "\(fileName)_\(preferredLanguageCode)"
            if let whatsNewFile = Bundle.main.url(forResource: localizedWhatsNewFileName, withExtension: ".json"), FileManager.default.fileExists(atPath: whatsNewFile.path) {
                fileName = localizedWhatsNewFileName
            }
        }
        
        guard
            let whatsNewFile = Bundle.main.url(forResource: fileName, withExtension: ".json")
        else {
            return .zero
        }

        do {
            let data = try Data(contentsOf: whatsNewFile)
            let json = try JSONDecoder().decode(WhatNewReleases.self, from: data)
            
            return json
        } catch {
            return .zero
        }

    }
}
