//
//  File.swift
//  
//
//  Created by Lukáš Korba on 24.05.2024.
//

import Foundation

public struct RPData: Codable, Equatable {
    public var address: String
    public var ammount: String
    public var memo: String

    public init(address: String, ammount: String, memo: String) {
        self.address = address
        self.ammount = ammount
        self.memo = memo
    }
}
