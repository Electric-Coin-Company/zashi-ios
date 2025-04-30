//
//  ReminedMeTimestamp.swift
//  modules
//
//  Created by Lukáš Korba on 10.04.2025.
//

import Foundation

public struct ReminedMeTimestamp: Equatable, Codable {
    public var timestamp: TimeInterval
    public var occurence: Int
    
    public init(timestamp: TimeInterval, occurence: Int) {
        self.timestamp = timestamp
        self.occurence = occurence
    }
}
