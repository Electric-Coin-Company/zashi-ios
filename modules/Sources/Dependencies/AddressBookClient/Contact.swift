//
//  Contact.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-28-2024.
//

import Foundation

public struct Contact: Equatable, Codable, Identifiable, Hashable {
    public let id: String
    public var name: String
    public var lastUpdated: Date
    public var chainId: String?

    public init(
        address: String,
        name: String,
        lastUpdated: Date = Date(),
        chainId: String? = nil
    ) {
        self.id = address
        self.name = name
        self.lastUpdated = lastUpdated
        self.chainId = chainId
    }
}
