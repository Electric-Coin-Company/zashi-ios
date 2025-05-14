//
//  ChainToken.swift
//  modules
//
//  Created by Lukáš Korba on 14.05.2025.
//

public struct ChainToken: Equatable, Codable, Identifiable, Hashable {
    public var id: String {
        "\(chain).\(token)"
    }
    
    public let chain: String
    public let token: String
    
    init(chain: String, token: String) {
        self.chain = chain
        self.token = token
    }
}
