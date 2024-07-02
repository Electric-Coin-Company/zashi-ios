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

    public init(address: String, name: String) {
        self.id = address
        self.name = name
    }
}
