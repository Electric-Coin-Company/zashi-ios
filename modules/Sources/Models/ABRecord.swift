//
//  ABRecord.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import Foundation

public struct ABRecord: Equatable, Codable, Identifiable, Hashable {
    public let id: String
    public var name: String
    public let timestamp: Date

    public init(address: String, name: String, timestamp: Date = Date()) {
        self.id = address
        self.name = name
        self.timestamp = timestamp
    }
}
