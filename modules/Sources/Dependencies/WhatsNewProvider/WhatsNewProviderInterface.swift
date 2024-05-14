//
//  WhatsNewProviderInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024.
//

import ComposableArchitecture

extension DependencyValues {
    public var whatsNewProvider: WhatsNewProviderClient {
        get { self[WhatsNewProviderClient.self] }
        set { self[WhatsNewProviderClient.self] = newValue }
    }
}

public struct WhatNewSection: Codable, Equatable {
    public var title: String
    public var bulletpoints: [String]
    
    public static let zero = WhatNewSection(title: "", bulletpoints: [])

    public init(title: String, bulletpoints: [String]) {
        self.title = title
        self.bulletpoints = bulletpoints
    }
}

public struct WhatNewRelease: Codable, Equatable {
    public var version: String
    public var date: String
    public var timestamp: Int
    public var sections: [WhatNewSection]

    public static let zero = WhatNewRelease(version: "", date: "", timestamp: 0, sections: [])

    public init(version: String, date: String, timestamp: Int, sections: [WhatNewSection]) {
        self.version = version
        self.date = date
        self.timestamp = timestamp
        self.sections = sections
    }
}

public struct WhatNewReleases: Codable, Equatable {
    public var releases: [WhatNewRelease]
    
    public static let zero = WhatNewReleases(releases: [])
    
    public init(releases: [WhatNewRelease]) {
        self.releases = releases
    }
}

public struct WhatsNewProviderClient {
    public var latest: () -> WhatNewRelease
    public var all: () -> WhatNewReleases
}
