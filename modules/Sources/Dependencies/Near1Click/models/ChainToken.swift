//
//  ChainToken.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

public struct ChainToken: Equatable, Codable, Identifiable, Hashable {
    public var id: String {
        pair.lowercased()
    }
    
    public var pair: String {
        "\(chain).\(token)"
    }
    
    public let chain: String
    public let token: String
    
    init(chain: String, token: String) {
        self.chain = chain
        self.token = token
    }
}
